import 'package:rg_event_management_ui/models/Employee.dart';
import 'package:rg_event_management_ui/models/User.dart';

class RgEmployeePayment {
  final int id;
  final Employee employee;
  final String paymentReason;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User addedBy;
  final User updateBy;

  RgEmployeePayment({
    required this.id,
    required this.employee,
    required this.paymentReason,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    required this.addedBy,
    required this.updateBy,
  });

  factory RgEmployeePayment.fromJson(Map<String, dynamic> json) {
    return RgEmployeePayment(
      id: json['id'],
      employee: Employee.fromJson(json['employee']),
      paymentReason: json['paymentReason'],
      amount: json['amount'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      addedBy: User.fromJson(json['addedBy']),
      updateBy: User.fromJson(json['updateBy']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'employee': employee.toJson(),
    'paymentReason': paymentReason,
    'amount': amount,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'addedBy': addedBy,
    'updateBy': updateBy,
  };
}