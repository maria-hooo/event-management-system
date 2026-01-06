import 'organizer.dart';

class EventModel {
  final String id;
  final String title; // stored lowercase by backend
  final String category;
  final int maxAttendees;
  final DateTime startDate;
  final bool isPublic;
  final List<String> tags;
  final Map<String, dynamic> extra;
  final double price;
  final Organizer organizer;

  EventModel({
    required this.id,
    required this.title,
    required this.category,
    required this.maxAttendees,
    required this.startDate,
    required this.isPublic,
    required this.tags,
    required this.extra,
    required this.price,
    required this.organizer,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final orgJson = json['organizerId'] as Map<String, dynamic>? ?? {};
    return EventModel(
      id: json['_id'] as String,
      title: (json['title'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      maxAttendees: (json['maxAttendees'] ?? 0) as int,
      startDate: DateTime.parse(json['startDate']),
      isPublic: (json['isPublic'] ?? true) as bool,
      tags: (json['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      extra: (json['extra'] as Map<String, dynamic>? ?? {}),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      organizer: Organizer.fromJson(orgJson),
    );
  }

  /// Convenience fields for existing UI
  String get displayTitle => title.isEmpty ? 'event' : '${title[0].toUpperCase()}${title.substring(1)}';

  String get location => (extra['location'] ?? 'Unknown') as String;

  String get imageUrl => (extra['imageUrl'] ?? 'https://picsum.photos/400/300?random=1') as String;
}
