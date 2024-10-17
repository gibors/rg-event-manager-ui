class Employee {

final int id;
final String name;
final String firstSurname;
final String secondSurname;
final String email;
final String phone;
final String position;

Employee({
  required this.id,
  required this.name,
  required this.firstSurname,
  required this.secondSurname,
  required this.email,
  required this.phone,
  required this.position,
});

factory Employee.fromJson(Map<String, dynamic> json) {
  return Employee(
    id: json['id'] ?? -1,
    name: json['name'] ?? '',
    firstSurname: json['firstSurname'] ?? '',
    secondSurname: json['secondSurname'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    position: json['position'] ?? '',
  );
}

Map<String, dynamic> toJson() => {
  'id': id == -1 ? null : id,
  'name': name,
  'firstSurname': firstSurname,
  'secondSurname': secondSurname,
  'email': email,
  'phone': phone,
  'position': position,
};
}

