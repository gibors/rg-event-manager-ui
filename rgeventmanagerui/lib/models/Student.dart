class Student {
  final int id;
  final String name;
  final int age;
  final String email;
  final String phone;
  final String packageType;
  final double additionalQuantity;
  final double totalCost;
  final int eventId;

  Student(
      {required this.id,
      required this.name,
      required this.age,
      required this.email,
      required this.phone,
      required this.packageType,
      required this.additionalQuantity,
      required this.totalCost,
      required this.eventId});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? -1,
      name: json['name'],
      age: json['age'],
      email: json['email'],
      phone: json['phone'],
      packageType: json['packageType'],
      additionalQuantity: json['additionalQuantity'],
      totalCost: json['totalCost'],
      eventId: json['eventId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id == -1 ? null : id,
    'name': name,
    'age': age,
    'email': email,
    'phone': phone,
    'packageType': packageType,
    'additionalQuantity': additionalQuantity,
    'totalCost': totalCost,
    'eventId': eventId,
  };

  
}