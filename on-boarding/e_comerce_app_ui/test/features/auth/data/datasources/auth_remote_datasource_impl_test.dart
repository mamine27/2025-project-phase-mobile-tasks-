import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartz/dartz.dart';
import 'package:e_comerce_app_ui/core/error/failure.dart';
import 'package:e_comerce_app_ui/features/auth/data/datasources/auth_local_datasource_impl.dart';
import 'package:e_comerce_app_ui/features/auth/data/models/user_model.dart';

void main() {
  late AuthLocalDatasourceImpl datasource;

  const tokenKey = 'access_token';
  const userKey = 'user_data';
  const token = 'sample_token';
  const testUserJson = '{"id":"1","email":"test@test.com","name":"Test User"}';
  final testUserModel = UserModel(
    id: '1',
    email: 'test@test.com',
    name: 'Test User',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    datasource = AuthLocalDatasourceImpl();
  });

  group('AccessToken', () {
    test('should save token successfully', () async {
      final result = await datasource.saveAccessToken(token);
      expect(result, equals(const Right(null)));
    });

    test('should get token if exists', () async {
      SharedPreferences.setMockInitialValues({tokenKey: token});
      datasource = AuthLocalDatasourceImpl();

      final result = await datasource.getAccessToken();
      expect(result, equals(Right(token)));
    });

    test('should fail to get token if not exists', () async {
      final result = await datasource.getAccessToken();
      expect(result.isLeft(), isTrue);
    });

    test('should clear token successfully', () async {
      SharedPreferences.setMockInitialValues({tokenKey: token});
      datasource = AuthLocalDatasourceImpl();

      final result = await datasource.clearAccessToken();
      expect(result, equals(const Right(null)));
    });
  });

  group('User', () {
    test('should save user successfully', () async {
      final result = await datasource.saveUser(testUserModel);
      expect(result, equals(const Right(null)));
    });

    test('should return user when it exists', () async {
      SharedPreferences.setMockInitialValues({userKey: testUserJson});
      datasource = AuthLocalDatasourceImpl();

      final result = await datasource.getUser();
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (user) => expect(user, equals(testUserModel)),
      );
    });

    test('should return failure when user not found', () async {
      final result = await datasource.getUser();
      expect(result.isLeft(), isTrue);
    });

    test('should clear user successfully', () async {
      SharedPreferences.setMockInitialValues({userKey: testUserJson});
      datasource = AuthLocalDatasourceImpl();

      final result = await datasource.clearUser();
      expect(result, equals(const Right(null)));
    });
  });
}
