class Ticket {
  final String id;
  final String eventId;
  final String buyerName;
  final int seatNumber;
  final DateTime purchaseDate;
  final bool checkedIn;
  final List<String> addons;
  final Map<String, dynamic> answers;

  Ticket({
    required this.id,
    required this.eventId,
    required this.buyerName,
    required this.seatNumber,
    required this.purchaseDate,
    required this.checkedIn,
    required this.addons,
    required this.answers,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id']?.toString() ?? '',
      eventId: json['eventId'] is Map<String, dynamic>
          ? (json['eventId']['_id']?.toString() ?? '')
          : (json['eventId']?.toString() ?? ''),
      buyerName: json['buyerName']?.toString() ?? '',
      seatNumber: (json['seatNumber'] is num) ? (json['seatNumber'] as num).toInt() : 0,
      purchaseDate: DateTime.tryParse(json['purchaseDate']?.toString() ?? '') ?? DateTime.now(),
      checkedIn: json['checkedIn'] == true,
      addons: (json['addons'] is List) ? (json['addons'] as List).map((e) => e.toString()).toList() : <String>[],
      answers: (json['answers'] is Map<String, dynamic>) ? (json['answers'] as Map<String, dynamic>) : <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'buyerName': buyerName,
      'seatNumber': seatNumber,
      'purchaseDate': purchaseDate.toIso8601String(),
      'checkedIn': checkedIn,
      'addons': addons,
      'answers': answers,
    };
  }
}
