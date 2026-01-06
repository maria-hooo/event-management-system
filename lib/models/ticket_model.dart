import 'event_model.dart';

class TicketModel {
  final String id;
  final String buyerName;
  final int seatNumber;
  final bool checkedIn;
  final DateTime purchaseDate;
  final List<String> notes;
  final Map<String, dynamic> payload;
  final EventModel event;

  TicketModel({
    required this.id,
    required this.buyerName,
    required this.seatNumber,
    required this.checkedIn,
    required this.purchaseDate,
    required this.notes,
    required this.payload,
    required this.event,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final eventJson = json['eventId'] as Map<String, dynamic>? ?? {};
    return TicketModel(
      id: (json['_id'] ?? '') as String,
      buyerName: (json['buyerName'] ?? '') as String,
      seatNumber: (json['seatNumber'] ?? 0) as int,
      checkedIn: (json['checkedIn'] ?? false) as bool,
      purchaseDate: DateTime.tryParse((json['purchaseDate'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
      notes: (json['notes'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      payload: (json['payload'] as Map<String, dynamic>? ?? {}),
      event: EventModel.fromJson(eventJson),
    );
  }
}
