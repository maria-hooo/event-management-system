class Organizer {
  final String id;
  final String orgName;
  final String phone;

  Organizer({required this.id, required this.orgName, required this.phone});

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      id: json['_id']?.toString() ?? '',
      orgName: json['orgName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orgName': orgName,
      'phone': phone,
    };
  }
}
