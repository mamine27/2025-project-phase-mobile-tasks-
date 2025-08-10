import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../features/auth/data/datasources/auth_remote_datasource_impl.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/chat/data/models/chat_model.dart';
import '../../features/chat/data/models/message_model.dart';
import '../../features/chat/domain/entities/message.dart';
import '../../injection_container.dart';

class WebSocketService {
  // REST may use /api/v3, socket.io usually root host
  static const String serverUrl =
      'https://g5-flutter-learning-path-be-tvum.onrender.com';

  final _authService = sl<AuthRemoteDataSourceImpl>();

  IO.Socket? _socket;
  IO.Socket? get raw => _socket;
  bool get isConnected => _socket?.connected == true;

  // Callbacks
  VoidCallback? onConnected;
  VoidCallback? onDisconnected;
  void Function(String error)? onMessageError;
  void Function(Message msg)? onMessageReceived;
  void Function(Message msg)? onMessageDelivered;

  final Set<String> _joinedRooms = {};

  bool _connecting = false;

  Future<void> connect({bool force = false}) async {
    if (isConnected && !force) {
      debugPrint('[SOCKET] Already connected');
      return;
    }
    if (_connecting) {
      debugPrint('[SOCKET] Connect already in progress');
      return;
    }
    _connecting = true;

    final tokenEither = await _authService.authLocalDatasource.getAccessToken();
    String? token;
    tokenEither.fold((f) {
      final msg = 'Token failure: ${f.message}';
      debugPrint('[SOCKET] $msg');
      onMessageError?.call(msg);
    }, (t) => token = t);

    _socket?.dispose();
    _socket = null;

    final opts = IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(5)
        .setReconnectionDelay(1000)
        .setQuery({'token': token ?? ''})
        .setExtraHeaders({if (token != null) 'Authorization': 'Bearer $token'})
        .build();

    debugPrint('[SOCKET] Attempt connect -> $serverUrl (websocket only)');
    _socket = IO.io(serverUrl, opts);

    _registerCoreHandlers();
    _addDebugHandlers();

    _socket!
      ..onConnect((_) {
        debugPrint('[SOCKET] CONNECT OK');
        onConnected?.call();
        for (final room in _joinedRooms) {
          _socket!.emit('chat:join', {'chatId': room});
        }
        _connecting = false;
      })
      ..on('connect_error', (e) {
        debugPrint('[SOCKET] connect_error: $e');
        if (!_socket!.connected) _connecting = false;
      })
      ..onError((e) {
        debugPrint('[SOCKET] error: $e');
        onMessageError?.call('error: $e');
      })
      ..onDisconnect((_) {
        debugPrint('[SOCKET] disconnected');
        onDisconnected?.call();
      });

    _socket!.connect();
  }

  void _addDebugHandlers() {
    final s = _socket;
    if (s == null) return;
    s
      ..on('connect_error', (e) {
        final msg = 'connect_error: $e';
        debugPrint('[SOCKET] $msg');
        onMessageError?.call(msg);
      })
      ..on('connect_timeout', (e) {
        final msg = 'connect_timeout: $e';
        debugPrint('[SOCKET] $msg');
        onMessageError?.call(msg);
      })
      ..on('error', (e) {
        final msg = 'error: $e';
        debugPrint('[SOCKET] $msg');
        onMessageError?.call(msg);
      })
      ..on('reconnect_failed', (_) {
        const msg = 'reconnect_failed';
        debugPrint('[SOCKET] $msg');
        onMessageError?.call(msg);
      })
      ..on('reconnect_error', (e) {
        final msg = 'reconnect_error: $e';
        debugPrint('[SOCKET] $msg');
        onMessageError?.call(msg);
      })
      ..on('ping', (_) => debugPrint('[SOCKET] ping'))
      ..on('pong', (lat) => debugPrint('[SOCKET] pong latency=$lat'))
      ..io.on('upgradeError', (e) {
        final msg = 'upgradeError: $e';
        debugPrint('[SOCKET] $msg');
        onMessageError?.call(msg);
      })
      ..io.on('open', (_) => debugPrint('[SOCKET] engine OPEN'))
      ..io.on('close', (_) => debugPrint('[SOCKET] engine CLOSE'));
  }

  void _registerCoreHandlers() {
    final s = _socket;
    if (s == null) return;

    s
      ..onConnect((_) {
        debugPrint('[SOCKET] Connected');
        onConnected?.call();
        for (final room in _joinedRooms) {
          s.emit('chat:join', {'chatId': room});
        }
      })
      ..onReconnectAttempt((_) => debugPrint('[SOCKET] Reconnect attempt'))
      ..onDisconnect((_) {
        debugPrint('[SOCKET] Disconnected');
        onDisconnected?.call();
      })
      ..on(
        'message:delivered',
        (data) => _parseAndEmitMessage(data, delivered: true),
      )
      ..on(
        'message:received',
        (data) => _parseAndEmitMessage(data, delivered: false),
      )
      ..on('message:error', (data) {
        final err = (data is Map && data['error'] != null)
            ? data['error'].toString()
            : 'Unknown error';
        final msg = 'Message error: $err';
        debugPrint('[SOCKET] $msg');
        onMessageError?.call(msg);
      })
      ..onError((e) {
        final msg = 'Socket error: $e';
        debugPrint('[SOCKET] $msg');
        onMessageError?.call(msg);
      });
  }

  void _parseAndEmitMessage(dynamic raw, {required bool delivered}) {
    try {
      if (raw is! Map) throw const FormatException('Invalid payload');
      final map = Map<String, dynamic>.from(raw);
      final payload = map['data'] is Map
          ? Map<String, dynamic>.from(map['data'])
          : map;

      final msg = MessageModel.fromJson(
        payload,
        chatFromJson: (c) {
          if (c is! Map) {
            debugPrint('[SOCKET] Invalid chat data: $c');
            return ChatModel.empty();
          }
          return ChatModel.fromJson(
            Map<String, dynamic>.from(c),
            userFromJson: (u) => _minimalUser(u),
          );
        },
        userFromJson: (u) => _minimalUser(Map<String, dynamic>.from(u)),
      );

      if (delivered) {
        onMessageDelivered?.call(msg);
      } else {
        onMessageReceived?.call(msg);
      }
    } catch (e) {
      final msg = 'Parse error: $e';
      debugPrint('[SOCKET] $msg');
      onMessageError?.call(msg);
    }
  }

  dynamic _minimalUser(Map<String, dynamic> json) => User(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    name: (json['name'] ?? json['fullName'] ?? '').toString(),
  );

  void sendMessage({
    required String chatId,
    required String content,
    String type = 'text',
  }) {
    if (!isConnected) {
      final msg = 'Not connected to server';
      debugPrint('[SOCKET] $msg');
      onMessageError?.call(msg);
      return;
    }
    final payload = {'chatId': chatId, 'content': content, 'type': type};
    debugPrint('[SOCKET] emit message:send -> $payload');
    _socket!.emit('message:send', payload);
  }

  void joinChat(String chatId) {
    if (!isConnected) {
      const msg = 'Join failed (not connected)';
      debugPrint('[SOCKET] $msg');
      onMessageError?.call(msg);
      return;
    }
    if (_joinedRooms.contains(chatId)) return;
    _socket!.emit('chat:join', {'chatId': chatId});
    _joinedRooms.add(chatId);
    debugPrint('[SOCKET] joined $chatId');
  }

  void leaveChat(String chatId) {
    if (!isConnected) return;
    if (!_joinedRooms.remove(chatId)) return;
    _socket!.emit('chat:leave', {'chatId': chatId});
    debugPrint('[SOCKET] left $chatId');
  }

  void disconnect() {
    try {
      _socket?.disconnect();
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
    _joinedRooms.clear();
  }
}
