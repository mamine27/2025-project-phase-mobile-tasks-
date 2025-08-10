import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/chat.dart';

class ChatModel extends Chat {
  const ChatModel({
    required String id,
    required User user1,
    required User user2,
  }) : super(id: id, user1: user1, user2: user2);

  factory ChatModel.fromJson(
    Map<String, dynamic> json, {
    required User Function(Map<String, dynamic>) userFromJson,
  }) {
    return ChatModel(
      id: (json['_id'] ?? json['id']).toString(),
      user1: userFromJson(
        Map<String, dynamic>.from(json['user1'] ?? json['sender'] ?? {}),
      ),
      user2: userFromJson(
        Map<String, dynamic>.from(json['user2'] ?? json['receiver'] ?? {}),
      ),
    );
  }

  static ChatModel empty() => ChatModel(
    id: '',
    user1: const User(id: '', email: '', name: ''),
    user2: const User(id: '', email: '', name: ''),
  );
}
