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

/// Remote + realtime (socket) implementation of ChatRemoteDataSource
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;
  final WebSocketService socketService;
  final String baseUrl;
  final Future<String?> Function() tokenProvider;
  final User Function(Map<String, dynamic>) userFromJson;

  ChatRemoteDataSourceImpl({
    required this.client,
    required this.socketService,
    required this.baseUrl,
    required this.tokenProvider,
    required this.userFromJson,
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
    return _wrapHttp<Chat>(
      'POST $u',
      () => client.post(
        Uri.parse(u),
        headers: _headers(token),
        body: jsonEncode({'userId': userId}),
      ),
      okCodes: const [200, 201],
      onOk: (res) {
        final data = jsonDecode(res.body);
        return ChatModel.fromJson(
          (data['data'] as Map<String, dynamic>),
          userFromJson: userFromJson,
        );
      },
    );
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

  @override
  Future<Message> sendMessage(
    String chatId,
    String content,
    String type,
  ) async {
    final token = await tokenProvider();
    if (token == null) throw CacheFailure('Missing token');
    final u = _url('/chats/$chatId/messages');
    debugPrint('[CHAT][HTTP][REQ] POST $u body={content:$content,type:$type}');
    return _wrapHttp<Message>(
      'POST $u',
      () => client.post(
        Uri.parse(u),
        headers: _headers(token),
        body: jsonEncode({'content': content, 'type': type}),
      ),
      okCodes: const [200, 201],
      onOk: (res) {
        final data = jsonDecode(res.body);
        final msgJson = data['data'] as Map<String, dynamic>;
        return MessageModel.fromJson(
          msgJson,
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
    final token = await tokenProvider();
    if (token == null) throw CacheFailure('Missing token');
    final u = _url('/chats/$chatId/messages');
    debugPrint('[CHAT][HTTP][REQ] GET $u');
    return _wrapHttp<List<Message>>(
      'GET $u',
      () => client.get(Uri.parse(u), headers: _headers(token)),
      onOk: (res) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List).cast<Map<String, dynamic>>();
        return list
            .map(
              (m) => MessageModel.fromJson(
                m,
                chatFromJson: (c) => ChatModel.fromJson(
                  (c as Map<String, dynamic>),
                  userFromJson: userFromJson,
                ),
                userFromJson: userFromJson,
              ),
            )
            .toList();
      },
    );
  }

  // ---------------- Realtime (Socket) ----------------

  @override
  Stream<Message> subscribeMessages(String chatId) {
    // Ensure connection (fire and forget)
    socketService.connect();

    final controller = StreamController<Message>.broadcast();
    final eventName = 'chat:$chatId:message';

    void handler(dynamic raw) {
      try {
        if (raw is! Map) throw const FormatException('Invalid message payload');
        final msg = MessageModel.fromJson(
          (raw as Map).cast<String, dynamic>(),
          chatFromJson: (c) => ChatModel.fromJson(
            (c as Map<String, dynamic>),
            userFromJson: userFromJson,
          ),
          userFromJson: userFromJson,
        );
        controller.add(msg);
      } catch (e) {
        controller.addError(e);
      }
    }

    // Add listener (requires socket getter in WebSocketService; add one if missing)
    // If you do not expose socket, create wrap methods in WebSocketService (on/off).
    socketService.raw?.on(eventName, handler);

    controller.onCancel = () {
      try {
        socketService.raw?.off(eventName, handler);
      } catch (_) {}
    };

    return controller.stream;
  }
}
