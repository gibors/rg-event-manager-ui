
class Student {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address


  Student(
      {required this.id,
      required this.name,
      required this.email,
      required this.phone,
      required this.address});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      address: json['address'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}