import 'package:rg_event_management_ui/models/Employee.dart';

class NominaEntry {
  final int id;
  final int nominaId;
  final Employee employee;
  final double baseSalary;
  final List<NominaBonusItem> bonuses;
  final double totalPayment;
  final String notes;

  NominaEntry({
    required this.id,
    required this.nominaId,
    required this.employee,
    required this.baseSalary,
    required this.bonuses,
    required this.totalPayment,
    required this.notes,
  });

  factory NominaEntry.fromJson(Map<String, dynamic> json) {
    var bonusList = <NominaBonusItem>[];
    if (json['bonuses'] != null) {
      bonusList = (json['bonuses'] as List)
          .map((b) => NominaBonusItem.fromJson(b))
          .toList();
    }
    return NominaEntry(
      id: json['id'] ?? 0,
      nominaId: json['nominaId'] ?? 0,
      employee: Employee.fromJson(json['employee']),
      baseSalary: (json['baseSalary'] ?? 0).toDouble(),
      bonuses: bonusList,
      totalPayment: (json['totalPayment'] ?? 0).toDouble(),
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id == 0 ? null : id,
        'nominaId': nominaId,
        'employee': employee.toJson(),
        'baseSalary': baseSalary,
        'bonuses': bonuses.map((b) => b.toJson()).toList(),
        'totalPayment': totalPayment,
        'notes': notes,
      };
}

class NominaBonusItem {
  final int id;
  final String concept;
  final double amount;

  NominaBonusItem({
    required this.id,
    required this.concept,
    required this.amount,
  });

  factory NominaBonusItem.fromJson(Map<String, dynamic> json) {
    return NominaBonusItem(
      id: json['id'] ?? 0,
      concept: json['concept'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id == 0 ? null : id,
        'concept': concept,
        'amount': amount,
      };
}
