import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user.dart' show User;
import '../models/user_model.dart';
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

        // Optionally fetch /users/me to cache user (so getCurrentUser works)
        try {
          final meResp = await apiClient.get(
            '/users/me',
            headers: {'Authorization': 'Bearer $token'},
          );
          if (meResp.statusCode == 200) {
            final meJson = jsonDecode(meResp.body);
            final userData = meJson['data'];
            if (userData != null) {
              final userModel = UserModel(
                id: (userData['_id'] ?? userData['id'] ?? '').toString(),
                email: userData['email'] ?? '',
                name: userData['name'] ?? '',
              );
              await authLocalDatasource.saveUser(userModel);
            }
          }
        } catch (_) {
          // silent; token still valid
        }

        return const Right(null);
      } else {
        return Left(ServerFailure(_extractMessage(response)));
      }
    } catch (e) {
      return Left(ServerFailure('Login error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        body: {'email': email, 'password': password, 'name': name},
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
  Future<Either<Failure, UserModel>> isSignedIn() async {
    try {
      // 1. Get token from local storage
      final tokenResult = await authLocalDatasource.getAccessToken();
      return await tokenResult.fold(
        (failure) async {
          return const Left(CacheFailure("no access token"));
        },
        (token) async {
          // 2. Send API request with token in headers
          final response = await apiClient.get(
            '/users/me',
            headers: {'Authorization': 'Bearer $token'},
          );

          // 3. Check response status

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final userData = data['data'];
            if (userData != null) {
              print("Access tole : $token");
              return Right(
                UserModel(
                  email: userData['email'] ?? '',
                  name: userData['name'] ?? '',
                  id: (userData['_id'] ?? userData['id'] ?? '').toString(),
                ),
              );
            } else {
              return const Left(ServerFailure('Invalid user data'));
            }
          } else {
            return Left(ServerFailure(_extractMessage(response)));
          }
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to check sign-in status: $e'));
    }
  }

  String _extractMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      print("data : $data");
      return data['message'] ?? 'Unknown error';
    } catch (_) {
      return 'Unknown error';
    }
  }
}
