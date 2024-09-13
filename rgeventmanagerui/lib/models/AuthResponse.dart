class AuthResponse {

  final String token;
  final String type;
  final String error;
  AuthResponse({required this.token, required this.type, required this.error});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? "",
      type: json['type'] ?? "",
      error: json['error'] ?? "",
    );
  }
}