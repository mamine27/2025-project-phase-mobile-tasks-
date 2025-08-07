import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'], email: json['email'], name: json['name']);
  }

  User toEntity() {
    return User(id: id, email: email, name: name);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email};
  }
}
