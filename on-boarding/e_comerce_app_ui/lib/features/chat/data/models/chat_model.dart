import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/chat.dart';

class ChatModel extends Chat {
  ChatModel({required super.id, required super.user1, required super.user2});

  factory ChatModel.fromJson(
    Map<String, dynamic> json, {
    required User Function(Map<String, dynamic>) userFromJson,
  }) {
    return ChatModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      user1: userFromJson(Map<String, dynamic>.from(json['user1'] ?? {})),
      user2: userFromJson(Map<String, dynamic>.from(json['user2'] ?? {})),
    );
  }

  static ChatModel empty() => ChatModel(
    id: '',
    user1: User(id: '', email: '', name: ''),
    user2: User(id: '', email: '', name: ''),
  );
}
