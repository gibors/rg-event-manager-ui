import 'package:rg_event_management_ui/models/User.dart';

class EventEmployeePayment {
  
  final int id;
  final int eventId;
  final String jobCategory;
  final String job;
  final double quantity;
  final double unitPayment;
  final double subtotal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User addedBy;
  final User updateBy;

  EventEmployeePayment({
    required this.id,
    required this.eventId,
    required this.jobCategory,
    required this.job,
    required this.quantity,
    required this.unitPayment,
    required this.subtotal,
    required this.createdAt,
    required this.updatedAt,
    required this.addedBy,
    required this.updateBy,
  });

  factory EventEmployeePayment.fromJson(Map<String, dynamic> json) {
    return EventEmployeePayment(
      id: json['id'],
      eventId: json['eventId'],
      jobCategory: json['jobCategory'],
      job: json['job'],
      quantity: json['quantity'],
      unitPayment: json['unitPayment'],
      subtotal: json['subtotal'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      addedBy: User.fromJson(json['addedBy']),
      updateBy: User.fromJson(json['updateBy']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id == 0 ? null : id,
    'eventId': eventId,
    'jobCategory': jobCategory,
    'job': job,
    'quantity': quantity,
    'unitPayment': unitPayment,
    'subtotal': subtotal,
    'createdAt': createdAt.toLocal().toIso8601String(),
    'updatedAt': updatedAt.toLocal().toIso8601String(),
    'addedBy': addedBy.toJson(),
    'updateBy': updateBy.toJson(),
  };

}