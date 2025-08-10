import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'core/network/socket.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_local_datasource_impl.dart';
import 'features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'features/chat/data/datasources/remote/chat_remote_datasource_impl.dart';
import 'features/auth/domain/entities/user.dart';

final sl = GetIt.instance;

const String kRestBase =
    'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v3';

void setupLocator() {
  // Http client
  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton<http.Client>(() => http.Client());
  }

  // Api client (if you have one already adjust)
  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(() => ApiClient());
  }

  // Auth local
  if (!sl.isRegistered<AuthLocalDatasourceImpl>()) {
    sl.registerLazySingleton<AuthLocalDatasourceImpl>(
      () => AuthLocalDatasourceImpl(),
    );
  }

  // Auth remote
  if (!sl.isRegistered<AuthRemoteDataSourceImpl>()) {
    sl.registerLazySingleton<AuthRemoteDataSourceImpl>(
      () => AuthRemoteDataSourceImpl(
        sl<ApiClient>(),
        sl<AuthLocalDatasourceImpl>(),
      ),
    );
  }

  // WebSocket
  if (!sl.isRegistered<WebSocketService>()) {
    sl.registerLazySingleton<WebSocketService>(() => WebSocketService());
  }

  // ChatRemoteDataSourceImpl deps:
  // - http.Client
  // - WebSocketService
  // - baseUrl (string)
  // - tokenProvider () => Future<String?>
  // - userFromJson mapper
  if (!sl.isRegistered<ChatRemoteDataSourceImpl>()) {
    sl.registerLazySingleton<ChatRemoteDataSourceImpl>(
      () => ChatRemoteDataSourceImpl(
        client: sl(),
        socketService: sl(),
        baseUrl: kRestBase,
        tokenProvider: () async => sl<AuthRemoteDataSourceImpl>()
            .authLocalDatasource
            .getAccessToken()
            .then((e) => e.fold((_) => null, (t) => t)),
        userFromJson: (m) => User(
          id: (m['_id'] ?? m['id'] ?? '').toString(),
          email: (m['email'] ?? '').toString(),
          name: (m['name'] ?? m['fullName'] ?? '').toString(),
        ),
      ),
    );
  }
  debugPrint('DI Chat baseUrl=${sl<ChatRemoteDataSourceImpl>().baseUrl}');
}
