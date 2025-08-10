import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;
  SendMessage(this.repository);

  Future<Either<Failure, Message>> call(
    String chatId,
    String message,
    String type,
  ) async => repository.sendMessage(chatId, message, type);
}
