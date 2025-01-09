class Additionalserviceresponse {

  final int items;
  final int saved;

  Additionalserviceresponse({
      required this.items,
      required this.saved,
    });

  factory Additionalserviceresponse.fromJson(Map<String, dynamic> json) {
    return Additionalserviceresponse(
      items: json['items'] ?? 0,
      saved: json['saved'] ?? 0,
    );
  }
}