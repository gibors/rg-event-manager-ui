import 'package:rg_event_management_ui/models/Event.dart';

class Supplier {
  final int id;
  final String name;
  final String lastName;
  final String email;
  final String phone;
  final String description;
  final double cost;
  final String costDescription;
  final ServiceType serviceType;
  final Location? location;
  final String accountNumber;

  Supplier(
      {required this.id,
      required this.name,
      required this.lastName,
      required this.email,
      required this.phone,
      required this.description,
      required this.cost,
      required this.costDescription,
      required this.serviceType,
      required this.location,
      required this.accountNumber,
      });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] ?? -1,
      name: json['name'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      description: json['description'] ?? "",
      cost: json['cost'],
      costDescription: json['costDescription'],
      serviceType: ServiceType.fromJson(json['serviceType']),
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      accountNumber: json['accountNumber'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id == -1 ? null : id,
    'name': name,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'description': description,
    'cost': cost,
    'costDescription': costDescription,
    'serviceType': serviceType.toJson(),
    'location': location?.toJson(),
    'accountNumber': accountNumber,
  };
}

class ServiceType {
  final int id;
  final String name;
  final String description;

  ServiceType(
      {required this.id,
      required this.name,
      required this.description,
});

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    return ServiceType(
      id: json['id'] ?? -1,
      name: json['name'],
      description: json['description'],

    );
  }

  Map<String, dynamic> toJson() => {
    'id': id == -1 ? null : id,
    'name': name,
    'description': description,
  };
}

