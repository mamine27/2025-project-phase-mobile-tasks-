import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/chat.dart';
import '../repositories/chat_repository.dart';

class GetUserChats {
  final ChatRepository repository;

  GetUserChats(this.repository);

  Future<Either<Failure, List<Chat>>> call() async {
    return await repository.getUserChats();
  }
}
