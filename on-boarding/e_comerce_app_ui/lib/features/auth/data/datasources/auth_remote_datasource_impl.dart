import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user.dart' show User;
import 'auth_local_datasource.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final AuthLocalDatasource authLocalDatasource;

  AuthRemoteDataSourceImpl(this.apiClient, this.authLocalDatasource);

  @override
  Future<Either<Failure, void>> signIn(String email, String password) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['data']['access_token'];
        await authLocalDatasource.saveAccessToken(token);
        return const Right(null);
      } else {
        return Left(ServerFailure(_extractMessage(response)));
      }
    } catch (e) {
      return Left(ServerFailure('Login error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signUp(String email, String password) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        body: {'email': email, 'password': password},
      );

      return response.statusCode == 201
          ? const Right(null)
          : Left(ServerFailure(_extractMessage(response)));
    } catch (e) {
      return Left(ServerFailure('Sign-up error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await authLocalDatasource.clearUser();
      await authLocalDatasource.clearAccessToken();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Sign out failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    final result = await authLocalDatasource.getUser();
    return result.fold(
      (failure) => Left(failure),
      (userModel) => Right(userModel.toEntity()),
    );
  }

  @override
  Future<Either<Failure, bool>> isSignedIn() async {
    try {
      final response = await apiClient.get('/auth/me');
      return Right(response.statusCode == 200);
    } catch (e) {
      return Left(ServerFailure('Failed to check sign-in status: $e'));
    }
  }

  String _extractMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'Unknown error';
    } catch (_) {
      return 'Unknown error';
    }
  }
}
