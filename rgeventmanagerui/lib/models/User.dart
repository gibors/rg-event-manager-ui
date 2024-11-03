class User {

  final int id;
  final String name;
  final String lastname;
  final String username;
  final String password;
  final String email;
  final int role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.lastname,
    required this.username,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      lastname: json['lastname'],
      username: json['username'],
      password: json['password'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id == -1 ? null : id,
      'name': name,
      'email': email,
      'lastname': lastname,
      'username': username,
      'password': password,
      'role': role,
    };
  }
}