import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repository;
  SignIn(this.repository);

  Future<Either<Failure, void>> call(String email, String password) async {
    return await repository.signIn(email, password);
  }
}
