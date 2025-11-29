import 'package:rg_event_management_ui/models/User.dart';

class AuthResponse {

  final String token;
  final String type;
  final String error;
  User? user;
  
  AuthResponse({required this.token, required this.type, required this.error, User? user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? "",
      type: json['type'] ?? "",
      error: json['error'] ?? "",
      user: json['user'] != null ? User.fromJson(json['user']) : null
    );
  }
}