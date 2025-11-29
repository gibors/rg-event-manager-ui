
import 'package:rg_event_management_ui/models/AdditionalService.dart';

class Event {
  final int id;
  final String name;
  final int minCapacity;
  final int folio;
  final EventType eventType;
  final Location location;
  final Pricing pricing;
  final List<Contact> contacts;
  final String? grade;
  final String? school;
  final String? carer;
  final DateTime createdDate;
  final DateTime eventDate;
  final DateTime updatedDate;
  final String createdBy;
  final String updatedBy;
  final String status;
  final double totalCost;
  final String? comments;
  final int numberChildren;
  final int numberYoung;
  final List<AdditionalService> additionalServices;
  double totalAdditional;
  
  Event({
    required this.id,
    required this.name,
    required this.eventDate,
    required this.minCapacity,
    required this.folio,
    required this.eventType,
    required this.location,
    required this.pricing,
    required this.contacts,
    required this.createdDate,
    required this.updatedDate,
    required this.createdBy,
    required this.updatedBy,
    required this.status,
    required this.grade,
    required this.school,
    required this.carer,
    required this.totalCost,
    required this.comments,
    required this.numberChildren,
    required this.numberYoung,
    required this.additionalServices,
    required this.totalAdditional,
  });

  void SetTotalAdditional(double totalAdditional) {
    this.totalAdditional = totalAdditional;
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? -1,
      name: json['name'] ?? '',
      minCapacity: json['minCapacity'] ?? 0,
      folio: json['folio'] ?? 0,
      eventType: EventType.fromJson(json['eventType']),
      location: Location.fromJson(json['location']),
      pricing: Pricing.fromJson(json['pricing']),
      contacts: (json['contacts'] as List)
          .map((contact) => Contact.fromJson(contact))
          .toList(),
      createdDate: DateTime.parse(json['createdDate']) ,
      eventDate: DateTime.parse(json['eventDate']),
      updatedDate: DateTime.parse(json['updatedDate']),
      createdBy: json['createdBy'] ?? '',
      updatedBy: json['updatedBy'] ?? '',
      status: json['status'] ?? '',
      grade: json['grade'],
      school: json['school'],
      carer: json['carer'],
      totalCost: json['totalCost'] ?? 0,
      comments: json['comments'],
      numberChildren: json['numberChildren'] ?? 0,
      numberYoung: json['numberYoung'] ?? 0,
      additionalServices: (json['additionalServices'] as List)
          .map((service) => AdditionalService.fromJson(service))
          .toList(),
      totalAdditional: json['totalAdditional'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id == -1 ? null : id,
      'name': name,
      'minCapacity': minCapacity,
      'folio': folio,
      'eventType': eventType.toJson(),
      'location': location.toJson(),
      'pricing': pricing.toJson(),
      'eventDate': eventDate.toLocal().toIso8601String(),
      // 'createdDate': createdDate.toLocal().toIso8601String(),
      // 'updatedDate': updatedDate.toLocal().toIso8601String(),
      'contacts': contacts.map((contact) => contact.toJson()).toList(),
      'grade': grade,
      'school': school,
      'carer':carer,
      'totalCost': totalCost,
      'comments': comments,
      'numberChildren': numberChildren,
      'numberYoung': numberYoung,
      'additionalServices': additionalServices.map((service) => service.toJson()).toList(),
      'totalAdditional': totalAdditional,
    };
  }
}

class Contact {
  final int id;
  final String name;
  final String phone;
  final String email;

  Contact(
      {required this.id,
      required this.name,
      required this.phone,
      required this.email});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] ?? -1,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id == -1 ? null : id,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }
}

class Address {
  final int id;
  final String number;
  final String street;
  final String city;
  final String state;
  final String zipCode;

  Address(
      {required this.id,
      required this.number,
      required this.street,
      required this.city,
      required this.state,
      required this.zipCode});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? -1,
      number: json['number'] ?? "",
      street: json['street'] ?? "",
      city: json['city'] ?? "",
      state: json['state'] ?? "",
      zipCode: json['zipCode'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id == -1 ? null : id,
      'number': number,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
    };
  }
}

class Location {
  final int id;
  final String locationName;
  final int capacity;
  final Address address;
  final String locationType;

  Location(
      {required this.id,
      required this.locationName,
      required this.capacity,
      required this.address,
      required this.locationType});

  factory Location.fromJson(Map<String, dynamic> json) {

      return Location(
      id: json['id'] ?? -1,
      locationName: json['locationName'] ?? "",
      capacity: json['capacity'] ?? 0,
      address: Address.fromJson(json['address']),
      locationType: json['locationType'] ?? "1",
    );
    
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id == -1 ? null : id,
      'locationName': locationName,
      'capacity': capacity,
      'address': address.toJson(),
      'locationType': locationType,
    };
  }
}

class EventType {
  final int id;
  final String description;

  EventType({required this.id, required this.description});

  factory EventType.fromJson(Map<String, dynamic> json) {
    return EventType(
      id: json['id'] ?? 0,
      description: json['description'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
    };
  }
}

class Pricing {
  final int id;
  final double dishCost;
  final double additionalCost;
  final double paq10TICost;
  final double paq10SPCost;
  final double paq5TIPCost;
  final double paq5SPCost;
  final double paq10DoubleCost;
  final double prePartyCost;
  final double braceletCost;
  final double childrenCost;
  final double youngCost;
  final double souvenirCost;
  Pricing(
      {required this.id,
      required this.dishCost,
      required this.additionalCost,
      required this.paq10TICost,
      required this.paq10SPCost,
      required this.paq5TIPCost,
      required this.paq5SPCost,
      required this.paq10DoubleCost,
      required this.prePartyCost,
      required this.braceletCost,
      required this.childrenCost,
      required this.youngCost,
      required this.souvenirCost
      });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      id: json['id'] ?? -1,
      dishCost: json['dishCost'] ?? 0,
      additionalCost: json['additionalCost'] ?? 0,
      paq10TICost: json['paq10TICost'] ?? 0,
      paq10SPCost: json['paq10SPCost'] ?? 0,
      paq5TIPCost: json['paq5TIPCost'] ?? 0,
      paq5SPCost: json['paq5SPCost'] ?? 0,
      paq10DoubleCost: json['paq10DoubleCost'] ?? 0,
      prePartyCost: json['prePartyCost'] ?? 0,
      braceletCost: json['braceletCost'] ?? 0,
      childrenCost: json['childrenCost'] ?? 0,
      youngCost: json['youngCost'] ?? 0,
      souvenirCost: json['souvenirCost'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id == -1 ? null : id,
      'dishCost': dishCost,
      'additionalCost': additionalCost,
      'paq10TICost': paq10TICost,
      'paq10SPCost': paq10SPCost,
      'paq5TIPCost': paq5TIPCost,
      'paq5SPCost': paq5SPCost,
      'paq10DoubleCost': paq10DoubleCost,
      'prePartyCost': prePartyCost,
      'braceletCost': braceletCost,
      'childrenCost': childrenCost,
      'youngCost': youngCost,
      'souvenirCost': souvenirCost,
    };
  }
}
