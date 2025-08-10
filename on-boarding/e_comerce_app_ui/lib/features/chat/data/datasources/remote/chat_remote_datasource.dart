import '../../../domain/entities/chat.dart';
import '../../../domain/entities/message.dart';

abstract class ChatRemoteDataSource {
  Future<List<Chat>> getUserChats();
  Future<Chat> getOrCreateChat(String receiverId);
  Future<void> deleteChat(String id);
  Future<Message> sendMessage(String chatId, String content, String type);
  Future<List<Message>> getChatHistory(String chatId);
  Stream<Message> subscribeMessages(String chatId);
}
