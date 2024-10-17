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
  final int folio;
  bool paid = false;

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
      required this.payments,
      required this.folio,
      });

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
      folio: json['folio'] ?? 0,
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
    'folio': folio,
  };  
}

  class Payment {
  final int id;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final int studentId;
  final int eventId;
  final String paymentDetail;

  Payment(
      {required this.id,
      required this.amount,
      required this.paymentMethod,
      required this.paymentDate,
      required this.studentId,
      required this.eventId,
      required this.paymentDetail,
      });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? -1,
      amount: json['amount'],
      paymentMethod: json['paymentMethod'],
      paymentDate: DateTime.parse(json['paymentDate']),
      studentId: json['studentId'] ?? -1,
      eventId: json['eventId'],
      paymentDetail: json['paymentDetail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id == -1 ? null : id,
    'amount': amount,
    'paymentMethod': paymentMethod,
    'paymentDate': paymentDate.toLocal().toIso8601String(),
    'studentId': studentId == -1 ? null : studentId,
    'eventId': eventId,
    'paymentDetail': paymentDetail,
  };
      
  }
