import '../../domain/entities/message.dart';
import '../../domain/entities/chat.dart';
import '../../../auth/domain/entities/user.dart';

class MessageModel extends Message {
  MessageModel({
    required String id,
    required Chat chat,
    required User sender,
    required String type,
    required String content,
  }) : super(id: id, chat: chat, sender: sender, type: type, content: content);

  factory MessageModel.fromJson(
    Map<String, dynamic> json, {
    required Chat Function(Map<String, dynamic>) chatFromJson,
    required User Function(Map<String, dynamic>) userFromJson,
  }) {
    final chatJson = Map<String, dynamic>.from(
      json['chat'] ?? json['conversation'] ?? {},
    );
    final senderJson = Map<String, dynamic>.from(json['sender'] ?? {});
    return MessageModel(
      id: (json['_id'] ?? json['id']).toString(),
      chat: chatFromJson(chatJson),
      sender: userFromJson(senderJson),
      type: (json['type'] ?? 'text').toString(),
      content: (json['content'] ?? '').toString(),
    );
  }

  toJson() {}
}
