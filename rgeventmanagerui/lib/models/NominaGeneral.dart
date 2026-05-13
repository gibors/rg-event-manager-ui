import 'package:rg_event_management_ui/models/User.dart';

class NominaGeneral {
  final int id;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // DRAFT, GENERATED, PAID
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User createdBy;

  NominaGeneral({
    required this.id,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory NominaGeneral.fromJson(Map<String, dynamic> json) {
    return NominaGeneral(
      id: json['id'],
      period: json['period'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'] ?? 'DRAFT',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: User.fromJson(json['createdBy']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id == 0 ? null : id,
        'period': period,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status,
        'totalAmount': totalAmount,
      };
}
