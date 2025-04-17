import 'package:rg_event_management_ui/models/Event.dart';
import 'package:rg_event_management_ui/models/Supplier.dart';
import 'package:rg_event_management_ui/models/User.dart';

class EventPay{
  
  final int id;
  final Event event;
  final Supplier supplier;
  final String paymentReason;
  final String description;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User addedBy;
  final User updateBy;

  EventPay({
    required this.id,
    required this.event,
    required this.supplier,
    required this.paymentReason,
    required this.description,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    required this.addedBy,
    required this.updateBy,
  });

  factory EventPay.fromJson(Map<String, dynamic> json) {
    return EventPay(
      id: json['id'],
      event: Event.fromJson(json['event']),
      supplier: Supplier.fromJson(json['supplier']),
      paymentReason: json['paymentReason'],
      description: json['description'],
      amount: json['amount'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      addedBy: User.fromJson(json['addedBy']),
      updateBy: User.fromJson(json['updateBy']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id == 0 ? null : id,
    'event': event.toJson(),
    'supplier': supplier.toJson(),
    'paymentReason': paymentReason,
    'description': description,
    'amount': amount,
    'createdAt': createdAt.toLocal().toIso8601String(),
    'updatedAt': updatedAt.toLocal().toIso8601String(),
    'addedBy': addedBy.toJson(),
    'updateBy': updateBy.toJson(),
  };

}