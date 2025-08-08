import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, void>> signIn(String email, String password);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> signUp(
    String email,
    String password,
    String name,
  );
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, UserModel>> isSignedIn();
}
