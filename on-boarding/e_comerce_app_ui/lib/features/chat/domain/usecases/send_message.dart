import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;
  SendMessage(this.repository);

  Future<Either<Failure, Unit>> call(
    String chatId,
    String message,
    String type,
  ) => repository.sendMessage(chatId, message, type);
}
