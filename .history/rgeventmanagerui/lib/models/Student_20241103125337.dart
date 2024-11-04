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
  List<Payment> payments;
  String folio;
  final int dishCount;
  final int additionalNumber;
  bool paid = false;

  void setFolio(String folio) {
    this.folio = folio;
  }

  void setPayments(List<Payment> payments) {
    this.payments = payments;
  }

  Student({
    required this.id,
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
    required this.dishCount,
    required this.additionalNumber,
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
      folio: json['folio'] ?? '',
      dishCount: json['dishCount'] ?? 0,
      additionalNumber: json['additionalNumber'] ?? 0,
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
        'dishCount': dishCount,
        'additionalNumber': additionalNumber,
      };
}

class Payment {
  final int id;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  int studentId;
  final int eventId;
  final String paymentDetail;
  final double iva;

  Payment({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    required this.studentId,
    required this.eventId,
    required this.paymentDetail,
    required this.iva,
  });

  void setStudent(int id) {
    this.studentId = id;
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? -1,
      amount: json['amount'],
      paymentMethod: json['paymentMethod'],
      paymentDate: DateTime.parse(json['paymentDate']),
      studentId: json['studentId'] ?? -1,
      eventId: json['eventId'],
      paymentDetail: json['paymentDetail'] ?? '',
      iva: json['iva'],
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
        'iva': iva,
      };
}
