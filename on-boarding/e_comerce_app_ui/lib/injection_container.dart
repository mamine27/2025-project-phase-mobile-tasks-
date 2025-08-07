import 'package:get_it/get_it.dart';
import 'features/auth/data/datasources/auth_remote_datasource_impl.dart';

final sl = GetIt.instance; // sl = service locator

void setupLocator(authclient, authlocal) {
  // Register your dependencies
  sl.registerLazySingleton<AuthRemoteDataSourceImpl>(
    () => AuthRemoteDataSourceImpl(authclient, authlocal),
  );
}
