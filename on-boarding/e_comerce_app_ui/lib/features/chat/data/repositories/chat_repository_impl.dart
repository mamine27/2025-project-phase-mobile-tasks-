import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remote;

  ChatRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Chat>> getOrCreateChat(receiver) async {
    try {
      final chat = await remote.getOrCreateChat(receiver.id);
      return Right(chat);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure('Unexpected: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Chat>>> getUserChats() async {
    try {
      final list = await remote.getUserChats();
      return Right(list);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure('Unexpected: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteChat(String id) async {
    try {
      await remote.deleteChat(id);
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure('Unexpected: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendMessage(
    String chatId,
    String message,
    String type,
  ) async {
    try {
      await remote.sendMessage(chatId, message, type);
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure('Unexpected: $e'));
    }
  }

  @override
  Stream<Either<Failure, Message>> getChatMessages(String id) {
    final controller = StreamController<Either<Failure, Message>>();
    StreamSubscription? sub;
    try {
      sub = remote
          .subscribeMessages(id)
          .listen(
            (m) => controller.add(Right(m)),
            onError: (err) =>
                controller.add(Left(ServerFailure(err.toString()))),
            onDone: controller.close,
            cancelOnError: false,
          );
    } catch (e) {
      controller.add(Left(ServerFailure('Unexpected: $e')));
      controller.close();
    }
    controller.onCancel = () => sub?.cancel();
    return controller.stream;
  }
}
