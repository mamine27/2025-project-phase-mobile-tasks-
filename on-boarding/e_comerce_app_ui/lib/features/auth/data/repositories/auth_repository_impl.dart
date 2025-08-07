import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required NetworkInfo networkInfo,
    required AuthRemoteDataSource remoteDataSource,
  }) : _networkInfo = networkInfo,
       _authRemoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, void>> signIn(String email, String password) async {
    if (await _networkInfo.isConnected) {
      return await _authRemoteDataSource.signIn(email, password);
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    if (await _networkInfo.isConnected) {
      return await _authRemoteDataSource.signOut();
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signUp(
    String email,
    String password,
    String name,
  ) async {
    if (await _networkInfo.isConnected) {
      return await _authRemoteDataSource.signUp(email, password, name);
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    if (await _networkInfo.isConnected) {
      return await _authRemoteDataSource.getCurrentUser();
    } else {
      return const Left(NetworkFailure());
    }
  }
}
