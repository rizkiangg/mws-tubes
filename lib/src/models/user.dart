import 'package:hive_flutter/hive_flutter.dart';

enum UserRole { user, admin }

class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final UserRole role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.role = UserRole.user,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool isAdmin() => role == UserRole.admin;

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'password': password,
    'role': role.toString(),
    'createdAt': createdAt.toIso8601String(),
  };

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    username: json['username'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
    role: (json['role'] as String?) == 'UserRole.admin'
        ? UserRole.admin
        : UserRole.user,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
  );

  @override
  String toString() => 'User(username: $username, email: $email, role: $role)';
}
