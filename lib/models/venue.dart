class Venue {
  final String id;
  final String name;
  final String address;
  final int capacityLimit;
  final Map<String, dynamic> locationJson;

  Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.capacityLimit,
    required this.locationJson,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      capacityLimit: (json['capacityLimit'] is num) ? (json['capacityLimit'] as num).toInt() : 0,
      locationJson: (json['locationJson'] is Map<String, dynamic>) ? (json['locationJson'] as Map<String, dynamic>) : <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'capacityLimit': capacityLimit,
      'locationJson': locationJson,
    };
  }
}
