import 'user.dart';

class Login {
  final String? token;
  final User user;

  Login({required this.token, required this.user});

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}
