import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../models/user_model.dart';

abstract class AuthLocalDatasource {
  Future<Either<Failure, void>> saveAccessToken(String token);
  Future<Either<Failure, String>> getAccessToken();
  Future<Either<Failure, void>> clearAccessToken();

  Future<Either<Failure, void>> saveUser(UserModel user);
  Future<Either<Failure, UserModel>> getUser();
  Future<Either<Failure, void>> clearUser();
}
