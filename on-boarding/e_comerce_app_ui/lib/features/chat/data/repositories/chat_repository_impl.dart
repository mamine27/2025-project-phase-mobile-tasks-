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
  Future<Either<Failure, Message>> sendMessage(
    String chatId,
    String message,
    String type,
  ) async {
    try {
      final msg = await remote.sendMessage(chatId, message, type);
      return Right(msg);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure('Unexpected: $e'));
    }
  }

  @override
  Future<Stream<Either<Failure, Message>>> getChatMessages(String id) async {
    try {
      final stream = remote
          .subscribeMessages(id)
          .map<Either<Failure, Message>>((msg) => Right(msg))
          .handleError((e, _) {
            return Left(ServerFailure(e.toString()));
          });
      return stream;
    } on Failure catch (f) {
      return Future.value(Stream.value(Left(f)));
    } catch (e) {
      return Future.value(Stream.value(Left(ServerFailure('Unexpected: $e'))));
    }
  }
}
