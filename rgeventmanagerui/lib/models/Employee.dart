class Employee {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String photo;

  Employee({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.photo,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'photo': photo,
    };
  }
}