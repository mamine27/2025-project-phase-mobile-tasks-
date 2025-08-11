import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/chat/domain/entities/message.dart';
import '../../features/chat/data/models/message_model.dart';
import '../../features/chat/data/models/chat_model.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../injection_container.dart';

class WebSocketService {
  WebSocketService({AuthLocalDatasource? authLocal})
    : _authLocal = authLocal ?? sl<AuthLocalDatasource>();

  static const String serverUrl =
      'https://g5-flutter-learning-path-be-tvum.onrender.com';
  IO.Socket? _socket;
  final AuthLocalDatasource _authLocal;

  // Event Callbacks
  Function(Message)? onMessageReceived;
  Function(Message)? onMessageDelivered;
  Function(String)? onMessageError;
  Function()? onConnected;
  Function()? onDisconnected;

  bool get isConnected => _socket?.connected ?? false;
  IO.Socket? get raw => _socket;

  String? _currentUserId;
  String? _lastToken;

  void setCurrentUserId(String? id) {
    if (id == null || id.isEmpty) return;
    _currentUserId = id;
    debugPrint('[SOCKET] 🔵 currentUserId set=$_currentUserId');
  }

  Future<void> connect() async {
    if (isConnected) {
      debugPrint('[SOCKET] 🔵 Already connected');
      return;
    }

    debugPrint('[SOCKET] 🚀 Starting connection to $serverUrl');

    try {
      // Get token
      debugPrint('[SOCKET] 🔍 Getting access token...');
      final tokenEither = await _authLocal.getAccessToken();

      tokenEither.fold(
        (f) {
          debugPrint('[SOCKET] ❌ Token error: ${f.message}');
          onMessageError?.call('No auth token: ${f.message}');
          return;
        },
        (t) {
          _lastToken = t.replaceAll(RegExp(r'\s+'), '');
          debugPrint(
            '[SOCKET] 🔑 Token loaded: ${_lastToken!.substring(0, 20)}...',
          );
          debugPrint('[SOCKET] 🔑 Full token length: ${_lastToken!.length}');

          // Decode JWT to see what's inside
          try {
            final parts = _lastToken!.split('.');
            if (parts.length == 3) {
              final payload = parts[1];
              final decoded = utf8.decode(
                base64Url.decode(payload + '=' * (4 - payload.length % 4)),
              );
              final data = jsonDecode(decoded);
              debugPrint('[SOCKET] 🔍 JWT payload: $data');
              debugPrint('[SOCKET] 🔍 JWT sub: ${data['sub']}');
              debugPrint('[SOCKET] 🔍 JWT email: ${data['email']}');
            }
          } catch (e) {
            debugPrint('[SOCKET] 🔴 JWT decode error: $e');
          }
        },
      );

      // Also try to load current user id from local cache
      try {
        final userEither = await _authLocal.getUser();
        userEither.fold(
          (f) => debugPrint('[SOCKET] ℹ️ No cached user: ${f.message}'),
          (u) {
            if ((u.id).toString().isNotEmpty) {
              _currentUserId = u.id.toString();
              debugPrint(
                '[SOCKET] 🔵 currentUserId (from cache)=$_currentUserId',
              );
            }
          },
        );
      } catch (e) {
        debugPrint('[SOCKET] ℹ️ Failed to read cached user: $e');
      }

      if (_lastToken == null || _lastToken!.isEmpty) {
        debugPrint('[SOCKET] ❌ No valid token available');
        onMessageError?.call('No auth token available');
        return;
      }

      // Create Socket.IO with auth in headers (like Postman)
      debugPrint(
        '[SOCKET] 🔧 Creating Socket.IO with auth in headers (like Postman)',
      );
      debugPrint(
        '[SOCKET] 🔧 Headers: Authorization: Bearer ${_lastToken!.substring(0, 20)}...',
      );

      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setExtraHeaders({'Authorization': 'Bearer ${_lastToken ?? ''}'})
            .build(),
      );

      debugPrint(
        '[SOCKET] 🔧 Socket.IO created, setting up event listeners...',
      );

      // Set up event listeners
      _socket!.onConnect((_) {
        final s = _socket!;
        debugPrint('[SOCKET] ✅ Connected! Socket ID: ${s.id}');
        debugPrint('[SOCKET] ✅ Connection state: ${s.connected}');
        debugPrint('[SOCKET] ✅ Transport: ${s.io.engine?.transport?.name}');
        onConnected?.call();
      });

      _socket!.onDisconnect((_) {
        debugPrint('[SOCKET] ❌ Disconnected');
        onDisconnected?.call();
      });

      _socket!.on('message:received', (data) {
        debugPrint('[SOCKET] 📨 Message received: $data');
        try {
          final msg = _safeParse(data);
          if (msg != null) onMessageReceived?.call(msg);
        } catch (e) {
          debugPrint('[SOCKET] 🔴 Parse error: $e');
        }
      });

      _socket!.on('message:delivered', (data) {
        debugPrint('[SOCKET] ✅ Message delivered: $data');
        try {
          final msg = _safeParse(data);
          if (msg != null) onMessageDelivered?.call(msg);
        } catch (e) {
          debugPrint('[SOCKET] 🔴 Parse error: $e');
        }
      });

      debugPrint(
        '[SOCKET] 🔧 Connection setup complete, waiting for connect...',
      );
    } catch (e) {
      debugPrint('[SOCKET] 🔴 Setup error: $e');
      debugPrint('[SOCKET] 🔴 Setup error stack: ${StackTrace.current}');
      onMessageError?.call('Setup error: $e');
    }
  }

  // Note: Room management (join/leave) is handled by backend. This client is send-only.

  void joinChat(String chatId) {
    // send-only mode: ignore join
    debugPrint('[SOCKET] ℹ️ joinChat ignored (send-only): $chatId');
  }

  void leaveChat(String chatId) {
    // send-only mode: ignore leave
    debugPrint('[SOCKET] ℹ️ leaveChat ignored (send-only): $chatId');
  }

  Future<void> sendMessage({
    required String chatId,
    required String content,
    String type = 'text',
  }) async {
    debugPrint(
      '[SOCKET] 📤 sendMessage called with: chatId=$chatId, content=$content, type=$type',
    );
    debugPrint(
      '[SOCKET] 📤 Current state: connected=$isConnected, currentUserId=$_currentUserId',
    );

    if (!isConnected) {
      debugPrint('[SOCKET] ❌ sendMessage failed: not connected');
      onMessageError?.call('Not connected to server');
      return;
    }

    if (chatId.isEmpty || content.trim().isEmpty) {
      debugPrint(
        '[SOCKET] ❌ sendMessage failed: invalid parameters - chatId: $chatId, content: ${content.trim()}',
      );
      onMessageError?.call('Invalid chat ID or content');
      return;
    }

    // send-only mode: do not auto-join rooms

    // Add userId to payload since JWT doesn't have 'sub' field
    final payload = {'chatId': chatId, 'content': content, 'type': type};

    debugPrint('[SOCKET][OUT][message:send] $payload');
    debugPrint(
      '[SOCKET][OUT][message:send] Socket state: ${_socket?.connected}',
    );
    debugPrint('[SOCKET][OUT][message:send] Socket ID: ${_socket?.id}');
    debugPrint(
      '[SOCKET][OUT][message:send] Using event: message:send (like Postman)',
    );
    debugPrint('[SOCKET][OUT][message:send] Added userId: $_currentUserId');

    try {
      // Emit exactly like Postman: 'message:send' event with payload
      _socket!.emit('message:send', payload);
      debugPrint(
        '[SOCKET] 📤 Message emitted successfully using message:send event',
      );
    } catch (e) {
      debugPrint('[SOCKET] 🔴 Error emitting message: $e');
      onMessageError?.call('Emit error: $e');
    }
  }

  Message? _safeParse(dynamic raw) {
    try {
      debugPrint(
        '[SOCKET] 🔍 Parsing message: $raw (type: ${raw.runtimeType})',
      );

      Map<String, dynamic>? map;
      if (raw is Map) {
        map = Map<String, dynamic>.from(raw);
      } else if (raw is String) {
        final d = jsonDecode(raw);
        if (d is Map) map = Map<String, dynamic>.from(d);
      }

      if (map == null) {
        debugPrint('[SOCKET] 🔴 Parse failed: map is null');
        return null;
      }

      debugPrint('[SOCKET] 🔍 Parsed map: $map');

      final inner = map['data'];
      final payload = inner is Map ? Map<String, dynamic>.from(inner) : map;

      debugPrint('[SOCKET] 🔍 Final payload: $payload');

      return MessageModel.fromJson(
        payload,
        chatFromJson: (c) => ChatModel.fromJson(
          Map<String, dynamic>.from(c),
          userFromJson: (u) => UserModel.fromJson(Map<String, dynamic>.from(u)),
        ),
        userFromJson: (u) => UserModel.fromJson(Map<String, dynamic>.from(u)),
      );
    } catch (e) {
      debugPrint('[SOCKET] 🔴 Parse error: $e');
      debugPrint('[SOCKET] 🔴 Parse error stack: ${StackTrace.current}');
      return null;
    }
  }

  void disconnect() {
    try {
      debugPrint('[SOCKET] 🔌 Disconnecting...');
      debugPrint('[SOCKET] 🔌 Socket state before: ${_socket?.connected}');
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      debugPrint('[SOCKET] 🔌 Disconnected and disposed');
    } catch (e) {
      debugPrint('[SOCKET] 🔴 Error during disconnect: $e');
    }
  }
}
