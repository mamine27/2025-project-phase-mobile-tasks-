import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/chat.dart';
import '../repositories/chat_repository.dart';

class GetOrCreateChat {
  final ChatRepository repository;
  GetOrCreateChat(this.repository);

  Future<Either<Failure, Chat>> call(User receiver) async {
    return await repository.getOrCreateChat(receiver);
  }
}
