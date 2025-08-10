import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetChatMessages {
  final ChatRepository repository;

  const GetChatMessages(this.repository);

  Future<Stream<Either<Failure, Message>>> call(String id) async {
    return await repository.getChatMessages(id);
  }
}
