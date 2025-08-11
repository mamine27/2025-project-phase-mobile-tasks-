import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../auth/domain/entities/user.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/entities/message.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import 'chat_remote_datasource.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/network/socket.dart';
import '../../../../auth/data/datasources/auth_local_datasource.dart';

/// Remote + realtime (socket) implementation of ChatRemoteDataSource
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;
  final WebSocketService socketService;
  final String baseUrl;
  final Future<String?> Function() tokenProvider;
  final User Function(Map<String, dynamic>) userFromJson;
  final AuthLocalDatasource authLocalDatasource;

  ChatRemoteDataSourceImpl({
    required this.client,
    required this.socketService,
    required this.baseUrl,
    required this.tokenProvider,
    required this.userFromJson,
    required this.authLocalDatasource,
  });

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  Future<T> _wrapHttp<T>(
    String label,
    Future<http.Response> Function() run, {
    required T Function(http.Response r) onOk,
    List<int> okCodes = const [200],
  }) async {
    final sw = Stopwatch()..start();
    http.Response res;
    try {
      res = await run();
    } catch (e) {
      throw ServerFailure('$label network error: $e');
    } finally {
      sw.stop();
    }
    debugPrint(
      '[CHAT][HTTP] $label status=${res.statusCode} ms=${sw.elapsedMilliseconds}',
    );
    if (!okCodes.contains(res.statusCode)) {
      final parsed = _tryParseError(res);
      throw ServerFailure('$label failed ${res.statusCode}: $parsed');
    }
    return onOk(res);
  }

  String _tryParseError(http.Response r) {
    try {
      final body = r.body;
      if (body.isEmpty) return 'empty body';
      final jsonObj = jsonDecode(body);
      if (jsonObj is Map) {
        return (jsonObj['message'] ??
                jsonObj['error'] ??
                jsonObj['msg'] ??
                jsonEncode(jsonObj))
            .toString();
      }
      return body;
    } catch (_) {
      return r.body;
    }
  }

  // ---------------- HTTP (REST) ----------------

  @override
  Future<List<Chat>> getUserChats() async {
    final token = await tokenProvider();
    if (token == null) throw CacheFailure('Missing token');

    return _wrapHttp<List<Chat>>(
      'GET /chats',
      () => client.get(Uri.parse(_url('/chats')), headers: _headers(token)),
      onOk: (res) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List).cast<Map<String, dynamic>>();
        return list
            .map((m) => ChatModel.fromJson(m, userFromJson: userFromJson))
            .toList();
      },
    );
  }

  String _url(String path) {
    assert(path.startsWith('/'));
    final b = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$b$path';
  }

  @override
  Future<Chat> getOrCreateChat(String userId) async {
    final token = await tokenProvider();
    if (token == null) throw CacheFailure('Missing token');
    final u = _url('/chats');
    debugPrint('[CHAT][HTTP][REQ] POST $u body={userId:$userId}');

    final chat = await _wrapHttp<Chat>(
      'POST $u',
      () => client.post(
        Uri.parse(u),
        headers: _headers(token),
        body: jsonEncode({'userId': userId}),
      ),
      okCodes: const [200, 201],
      onOk: (res) {
        final body = jsonDecode(res.body);
        final data = body['data'];
        if (data is! Map) {
          throw ServerFailure('Invalid chat response');
        }
        return ChatModel.fromJson(
          Map<String, dynamic>.from(data),
          userFromJson: userFromJson,
        );
      },
    );

    // Get current user from auth system after chat is created
    final currentUserResult = await authLocalDatasource.getUser();
    currentUserResult.fold(
      (failure) {
        debugPrint('[CHAT] Failed to get current user: ${failure.message}');
        // Fallback to chat user2 (the one who initiated the chat)
        final fallbackUserId = chat.user2.id.isNotEmpty
            ? chat.user2.id
            : chat.user1.id;
        debugPrint('[CHAT] Using fallback user ID: $fallbackUserId');
        socketService.setCurrentUserId(fallbackUserId);
      },
      (currentUser) {
        debugPrint(
          '[CHAT] Setting current user ID from auth: ${currentUser.id}',
        );
        socketService.setCurrentUserId(currentUser.id);
      },
    );

    // Join enriched
    socketService.joinChat(chat.id);
    return chat;
  }

  @override
  Future<void> deleteChat(String id) async {
    final token = await tokenProvider();
    if (token == null) throw CacheFailure('Missing token');
    final u = _url('/chats/$id');
    debugPrint('[CHAT][HTTP][REQ] DELETE $u');
    await _wrapHttp<void>(
      'DELETE $u',
      () => client.delete(Uri.parse(u), headers: _headers(token)),
      onOk: (_) {},
    );
  }

  Future<void> _ensureSocketConnected() async {
    if (socketService.isConnected) return;
    final c = Completer<void>();
    void done() {
      if (!c.isCompleted) c.complete();
      socketService.onConnected = null;
    }

    socketService.onConnected = done;
    await socketService.connect();
    // fallback timeout
    await Future.any([c.future, Future.delayed(const Duration(seconds: 5))]);
  }

  @override
  Future<void> sendMessage(String chatId, String content, String type) async {
    if (chatId.isEmpty) throw ArgumentError('chatId empty');
    if (content.trim().isEmpty) throw ArgumentError('content empty');
    await socketService.connect(); // idempotent
    await socketService.sendMessage(
      chatId: chatId,
      content: content,
      type: type.isEmpty ? 'text' : type,
    );
  }

  @override
  Stream<Message> subscribeMessages(String chatId) {
    final controller = StreamController<Message>.broadcast();
    _ensureSocketConnected();

    Message _parse(dynamic raw) {
      if (raw is! Map) throw const FormatException('Invalid message payload');
      final root = Map<String, dynamic>.from(raw);
      final payload = (root['data'] is Map)
          ? Map<String, dynamic>.from(root['data'])
          : root;
      return MessageModel.fromJson(
        payload,
        chatFromJson: (c) {
          if (c is Map<String, dynamic>) {
            return ChatModel.fromJson(c, userFromJson: userFromJson);
          }
          final fallbackId = (payload['chatId'] ?? chatId).toString();
          return ChatModel.fromJson({
            '_id': fallbackId,
          }, userFromJson: userFromJson);
        },
        userFromJson: userFromJson,
      );
    }

    void delivered(dynamic raw) {
      try {
        final msg = _parse(raw);
        if (msg.chat.id == chatId) controller.add(msg);
      } catch (e, st) {
        controller.addError(e, st);
      }
    }

    void received(dynamic raw) {
      try {
        final msg = _parse(raw);
        if (msg.chat.id == chatId) controller.add(msg);
      } catch (e, st) {
        controller.addError(e, st);
      }
    }

    socketService.raw?.on('message:delivered', delivered);
    socketService.raw?.on('message:received', received);

    controller.onCancel = () {
      try {
        socketService.raw?.off('message:delivered', delivered);
        socketService.raw?.off('message:received', received);
      } catch (_) {}
    };

    return controller.stream;
  }

  // Add optional method (only if backend supports this endpoint)
  Future<Message?> sendMessageHttp(
    String chatId,
    String content,
    String type,
  ) async {
    final token = await tokenProvider();
    if (token == null) throw CacheFailure('Missing token');
    final u = _url('/chats/$chatId/messages');
    debugPrint('[CHAT][HTTP][REQ] POST $u body={content:$content,type:$type}');
    return _wrapHttp<Message?>(
      'POST $u',
      () => client.post(
        Uri.parse(u),
        headers: _headers(token),
        body: jsonEncode({'content': content, 'type': type}),
      ),
      okCodes: const [200, 201],
      onOk: (res) {
        final data = jsonDecode(res.body);
        final m = (data['data'] ?? {}) as Map<String, dynamic>;
        return MessageModel.fromJson(
          m,
          chatFromJson: (c) => ChatModel.fromJson(
            (c as Map<String, dynamic>),
            userFromJson: userFromJson,
          ),
          userFromJson: userFromJson,
        );
      },
    );
  }

  @override
  Future<List<Message>> getChatHistory(String chatId) async {
    if (chatId.isEmpty) throw ArgumentError('chatId empty');
    final token = await tokenProvider();
    if (token == null) throw CacheFailure('Missing token');

    final u = _url('/chats/$chatId/messages');
    debugPrint('[CHAT][HTTP][REQ] GET $u');
    return _wrapHttp<List<Message>>(
      'GET $u',
      () => client.get(Uri.parse(u), headers: _headers(token)),
      onOk: (res) {
        final body = jsonDecode(res.body);
        final rawList = body is Map ? body['data'] : null;
        if (rawList is! List) return <Message>[];

        return rawList
            .whereType<Map>() // only map items
            .map((m) => Map<String, dynamic>.from(m as Map))
            .map(
              (m) => MessageModel.fromJson(
                m,
                chatFromJson: (c) {
                  if (c is Map<String, dynamic>) {
                    return ChatModel.fromJson(c, userFromJson: userFromJson);
                  }
                  // fallback if backend only provides chatId
                  final cid = (m['chatId'] ?? chatId).toString();
                  return ChatModel.fromJson({
                    '_id': cid,
                  }, userFromJson: userFromJson);
                },
                userFromJson: userFromJson,
              ),
            )
            .toList();
      },
    );
  }
}

class ChatIdResolver {
  final ChatRemoteDataSource ds;
  final _cache = <String, String>{}; // otherUserId -> chatId
  ChatIdResolver(this.ds);

  Future<String> resolve(String otherUserId) async {
    final cached = _cache[otherUserId];
    if (cached != null) return cached;
    final chat = await ds.getOrCreateChat(otherUserId);
    _cache[otherUserId] = chat.id;
    return chat.id;
  }
}
