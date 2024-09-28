import 'package:rg_event_management_ui/models/Event.dart';

class Provider {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String description;
  final double cost;
  final String costDescription;
  final ServiceType serviceType;
  final Location location;

  Provider(
      {required this.id,
      required this.name,
      required this.email,
      required this.phone,
      required this.description,
      required this.cost,
      required this.costDescription,
      required this.serviceType,
      required this.location});

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'] ?? -1,
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      description: json['description'],
      cost: json['cost'],
      costDescription: json['costDescription'],
      serviceType: ServiceType.fromJson(json['serviceType']),
      location: Location.fromJson(json['location']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id == -1 ? null : id,
    'name': name,
    'email': email,
    'phone': phone,
    'description': description,
    'cost': cost,
    'costDescription': costDescription,
    'serviceType': serviceType.toJson(),
    'location': location.toJson(),
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

