import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/socket.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_local_datasource_impl.dart';
import 'features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'features/chat/data/datasources/remote/chat_remote_datasource_impl.dart';
import 'features/auth/domain/entities/user.dart';

final sl = GetIt.instance;

const String kRestBase =
    'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v3';

Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();

  // Auth local (interface -> impl)
  if (!sl.isRegistered<AuthLocalDatasource>()) {
    sl.registerLazySingleton<AuthLocalDatasource>(
      () => AuthLocalDatasourceImpl(prefs),
    );
  }

  // HTTP client
  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton<http.Client>(() => http.Client());
  }

  // Api client
  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(() => ApiClient());
  }

  // Auth remote (use interface type, DO NOT request impl that is not registered)
  if (!sl.isRegistered<AuthRemoteDataSourceImpl>()) {
    sl.registerLazySingleton<AuthRemoteDataSourceImpl>(
      () =>
          AuthRemoteDataSourceImpl(sl<ApiClient>(), sl<AuthLocalDatasource>()),
    );
  }

  // Socket (after auth local so it can pull token)
  if (!sl.isRegistered<WebSocketService>()) {
    sl.registerLazySingleton<WebSocketService>(() => WebSocketService());
  }

  // Chat remote
  if (!sl.isRegistered<ChatRemoteDataSourceImpl>()) {
    sl.registerLazySingleton<ChatRemoteDataSourceImpl>(
      () => ChatRemoteDataSourceImpl(
        client: sl<http.Client>(),
        socketService: sl<WebSocketService>(),
        baseUrl: kRestBase,
        tokenProvider: () async => sl<AuthLocalDatasource>()
            .getAccessToken()
            .then((e) => e.fold((_) => null, (t) => t)),
        userFromJson: (m) => User(
          id: (m['_id'] ?? m['id'] ?? '').toString(),
          email: (m['email'] ?? '').toString(),
          name: (m['name'] ?? m['fullName'] ?? '').toString(),
        ),
        authLocalDatasource: sl<AuthLocalDatasource>(),
      ),
    );
  }

  debugPrint('DI ready: baseUrl=${sl<ChatRemoteDataSourceImpl>().baseUrl}');
}
