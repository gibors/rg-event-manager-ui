import 'package:rg_event_management_ui/models/Supplier.dart';

class AdditionalService {

  final int id;
  final String description;
  final int eventId;
  final ServiceType serviceType;
  final Supplier? supplier;
  final int quantity;
  final double cost;
  final double supplierCost;

  AdditionalService({
      required this.id,
      required this.description,
      required this.eventId,
      required this.serviceType,
      required this.supplier,
      required this.quantity,
      required this.cost,
      required this.supplierCost,
    });

  factory AdditionalService.fromJson(Map<String, dynamic> json) {
    return AdditionalService(
      id: json['id'] ?? 0,
      description: json['description'] ?? "",
      eventId: json['eventId'] ?? 0,
      serviceType: ServiceType.fromJson(json['serviceType']),
      supplier: json['supplier'] != null ? Supplier.fromJson(json['supplier']) : null,
      quantity: json['quantity'] ?? 0,
      cost: json['cost'] ?? 0.0,
      supplierCost: json['supplierCost'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id == 0 ? null : id,
      'description': description,
      'eventId': eventId,
      'serviceType': serviceType.toJson(),
      'supplier': supplier?.toJson() ,
      'quantity': quantity,
      'cost': cost,
      'supplierCost': supplierCost,
    };
  }
     

   
}