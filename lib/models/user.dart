import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String city;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
  });

  /// Factory to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['tel'] ?? '',
      city: json['ville'] ?? '',
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'tel': phone,
      'ville': city,
    };
  }

  /// Parse from JSON string
  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  /// Convert to JSON string
  String toRawJson() => json.encode(toJson());
}
