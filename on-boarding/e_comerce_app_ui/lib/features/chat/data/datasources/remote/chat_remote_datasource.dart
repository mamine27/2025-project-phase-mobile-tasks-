import '../../../domain/entities/chat.dart';
import '../../../domain/entities/message.dart';

abstract class ChatRemoteDataSource {
  Future<List<Chat>> getUserChats();
  Future<Chat> getOrCreateChat(String userId);
  Future<void> deleteChat(String id);
  Future<void> sendMessage(
    String chatId,
    String content,
    String type,
  ); // changed return type
  Future<List<Message>> getChatHistory(String chatId);
  Stream<Message> subscribeMessages(String chatId);
}
