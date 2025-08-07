import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failure.dart';
import '../models/user_model.dart';
import 'auth_local_datasource.dart';

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_data';

  @override
  Future<Either<Failure, void>> saveAccessToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_tokenKey, token);
      return success
          ? const Right(null)
          : const Left(CacheFailure('Failed to save access token'));
    } catch (e) {
      return Left(CacheFailure('Exception saving token: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return token != null
          ? Right(token)
          : const Left(CacheFailure('Access token not found'));
    } catch (e) {
      return Left(CacheFailure('Exception getting token: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_tokenKey);
      return success
          ? const Right(null)
          : const Left(CacheFailure('Failed to clear access token'));
    } catch (e) {
      return Left(CacheFailure('Exception clearing token: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(user.toJson());
      final success = await prefs.setString(_userKey, jsonString);
      return success
          ? const Right(null)
          : const Left(CacheFailure('Failed to save user'));
    } catch (e) {
      return Left(CacheFailure('Exception saving user: $e'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_userKey);
      if (jsonString == null) {
        return const Left(CacheFailure('User not found'));
      }
      final jsonData = json.decode(jsonString);
      final user = UserModel.fromJson(jsonData);
      return Right(user);
    } catch (e) {
      return Left(CacheFailure('Exception getting user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_userKey);
      return success
          ? const Right(null)
          : const Left(CacheFailure('Failed to clear user'));
    } catch (e) {
      return Left(CacheFailure('Exception clearing user: $e'));
    }
  }
}
