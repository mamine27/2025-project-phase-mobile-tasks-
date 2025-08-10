import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/chat/data/datasources/remote/chat_remote_datasource.dart';
import 'features/auth/data/models/user_model.dart'; // adjust actual file
import 'features/chat/data/datasources/remote/chat_remote_datasource_impl.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'injection_container.dart';

void registerChatModule() {
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(
      client: sl(),
      socketService: sl(),
      baseUrl: 'https://your.api.base', // adjust
      tokenProvider: () async {
        final either = await sl<AuthLocalDatasource>().getAccessToken();
        return either.fold((_) => null, (t) => t);
      },
      userFromJson: (m) => UserModel.fromJson(m), // FIX: was ChatModel
    ),
  );

  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
}
