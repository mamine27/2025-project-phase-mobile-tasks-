import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/chat/data/datasources/remote/chat_remote_datasource.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/chat/data/datasources/remote/chat_remote_datasource_impl.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/domain/usecases/get_user_chats.dart';
import 'features/chat/domain/usecases/get_or_create_chat.dart';
import 'features/chat/domain/usecases/get_chat_messages.dart';
import 'features/chat/domain/usecases/send_message.dart';
import 'injection_container.dart';

void registerChatModule() {
  // Register chat remote data source
  if (!sl.isRegistered<ChatRemoteDataSource>()) {
    sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(
        client: sl(),
        socketService: sl(),
        baseUrl: 'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v3',
        tokenProvider: () async {
          final either = await sl<AuthLocalDatasource>().getAccessToken();
          return either.fold((_) => null, (t) => t);
        },
        userFromJson: (m) =>
            UserModel.fromJson(Map<String, dynamic>.from(m as Map)),
        authLocalDatasource: sl<AuthLocalDatasource>(),
      ),
    );
  }

  // Register chat repository
  if (!sl.isRegistered<ChatRepository>()) {
    sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
  }

  // Register chat use cases
  if (!sl.isRegistered<GetUserChats>()) {
    sl.registerLazySingleton<GetUserChats>(() => GetUserChats(sl()));
  }

  if (!sl.isRegistered<GetOrCreateChat>()) {
    sl.registerLazySingleton<GetOrCreateChat>(() => GetOrCreateChat(sl()));
  }

  if (!sl.isRegistered<GetChatMessages>()) {
    sl.registerLazySingleton<GetChatMessages>(() => GetChatMessages(sl()));
  }

  if (!sl.isRegistered<SendMessage>()) {
    sl.registerLazySingleton<SendMessage>(() => SendMessage(sl()));
  }
}
