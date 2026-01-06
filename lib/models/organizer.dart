class Organizer {
  final String id;
  final String name;
  final String? phone;
  final String? email;

  Organizer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      id: json['_id'] as String,
      name: (json['name'] ?? json['orgName'] ?? '') as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );
  }
}
