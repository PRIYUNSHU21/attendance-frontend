import 'dart:convert';

class User {
  final String userId;
  final String name;
  final String email;
  final String role;
  final String orgId;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.orgId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      orgId: json['org_id'] ?? '',
    );
  }

  factory User.fromJsonString(String jsonString) {
    return User.fromJson(jsonDecode(jsonString));
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name': name,
    'email': email,
    'role': role,
    'org_id': orgId,
  };

  String toJsonString() => jsonEncode(toJson());
} 