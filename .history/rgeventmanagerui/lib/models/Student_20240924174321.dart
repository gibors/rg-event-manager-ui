class Student {
  final int id;
  final String name;
  final String lastName;
  final int age;
  final String email;
  final String phone;
  final String packageType;
  final double additionalQuantity;
  final double totalCost;
  final int eventId;
  final String comments;
  final List<Payment> payments;

  Student(
      {required this.id,
      required this.name,
      required this.lastName,
      required this.age,
      required this.email,
      required this.phone,
      required this.packageType,
      required this.additionalQuantity,
      required this.totalCost,
      required this.eventId,
      required this.comments,
      required this.payments});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? -1,
      name: json['name'],
      lastName: json['lastName'],
      age: json['age'],
      email: json['email'],
      phone: json['phone'],
      packageType: json['packageType'],
      additionalQuantity: json['additionalQuantity'],
      totalCost: json['totalCost'],
      eventId: json['eventId'],
      comments: json['comments'],
      payments: (json['payments'] as List)
          .map((payment) => Payment.fromJson(payment))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id == -1 ? null : id,
    'name': name,
    'lastName': lastName,
    'age': age,
    'email': email,
    'phone': phone,
    'packageType': packageType,
    'additionalQuantity': additionalQuantity,
    'totalCost': totalCost,
    'eventId': eventId,
    'comments': comments,
    'payments': payments.map((payment) => payment.toJson()).toList(),
  };  
}

  class Payment {
  final int id;
  final double amount;
  final String paymentMethod;
  final String paymentDate;
  final int studentId;
  final int eventId;

  Payment(
      {required this.id,
      required this.amount,
      required this.paymentMethod,
      required this.paymentDate,
      required this.studentId,
      required this.eventId});

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? -1,
      amount: json['amount'],
      paymentMethod: json['paymentMethod'],
      paymentDate: json['paymentDate'],
      studentId: json['studentId'],
      eventId: json['eventId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id == -1 ? null : id,
    'amount': amount,
    'paymentMethod': paymentMethod,
    'paymentDate': paymentDate,
    'studentId': studentId,
    'eventId': eventId,
  };
      
  }
