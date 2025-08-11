import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failure.dart';
import '../models/user_model.dart';
import 'auth_local_datasource.dart';

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  static const _kToken = 'auth_token';
  static const String _userKey = 'user_data';
  final SharedPreferences prefs;
  AuthLocalDatasourceImpl(this.prefs);

  @override
  Future<Either<Failure, void>> saveAccessToken(String token) async {
    try {
      final clean = token.replaceAll(RegExp(r'\s+'), '');
      debugPrint('[AUTH][STORE] tokenLen=${clean.length}');
      final ok = await prefs.setString(_kToken, clean);
      return ok ? const Right(null) : const Left(CacheFailure('save failed'));
    } catch (e) {
      return Left(CacheFailure('Save token error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getAccessToken() async {
    try {
      final t = prefs.getString(_kToken);
      if (t == null || t.isEmpty) {
        return const Left(CacheFailure('No access token'));
      }
      return Right(t);
    } catch (e) {
      return Left(CacheFailure('Read token error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAccessToken() async {
    try {
      await prefs.remove(_kToken);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Exception clearing token: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUser(UserModel user) async {
    try {
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
      final success = await prefs.remove(_userKey);
      return success
          ? const Right(null)
          : const Left(CacheFailure('Failed to clear user'));
    } catch (e) {
      return Left(CacheFailure('Exception clearing user: $e'));
    }
  }
}
