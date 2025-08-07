import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repository;
  SignUp(this.repository);

  Future<Either<Failure, void>> call(
    String email,
    String password,
    String Name,
  ) async {
    return await repository.signUp(email, password, Name);
  }
}
