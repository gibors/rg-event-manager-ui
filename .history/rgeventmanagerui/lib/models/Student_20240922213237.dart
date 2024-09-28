class Student {
  final int id;
  final String name;
  final int age;
  final String email;
  final String phone;
  final String packageType;
  final double additionalQuatity;
  final double totalCost;
  final int eventId;

  Student({this.id, this.name, this.age, this.email, this.phone, this.packageType, this.additionalQuatity, this.totalCost, this.eventId});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      email: json['email'],
      phone: json['phone'],
      packageType: json['packageType'],
      additionalQuatity: json['additionalQuatity'],
      totalCost: json['totalCost'],
      eventId: json['eventId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'email': email,
    'phone': phone,
    'packageType': packageType,
    'additionalQuatity': additionalQuatity,
    'totalCost': totalCost,
    'eventId': eventId,
  };

  
}