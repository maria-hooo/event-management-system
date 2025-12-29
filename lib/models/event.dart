import 'organizer.dart';
import 'venue.dart';

class EventItem {
  final String id;
  final String title;
  final String eventType;
  final int capacity;
  final DateTime eventDate;
  final bool isPublic;
  final List<String> tags;
  final Map<String, dynamic> extraInfo;
  final String contactEmail;

  // Foreign keys + populated objects (either string id or populated map)
  final String organizerId;
  final Organizer? organizer;
  final String venueId;
  final Venue? venue;

  EventItem({
    required this.id,
    required this.title,
    required this.eventType,
    required this.capacity,
    required this.eventDate,
    required this.isPublic,
    required this.tags,
    required this.extraInfo,
    required this.contactEmail,
    required this.organizerId,
    required this.organizer,
    required this.venueId,
    required this.venue,
  });

  static Organizer? _parseOrganizer(dynamic v) {
    if (v is Map<String, dynamic>) return Organizer.fromJson(v);
    return null;
  }

  static Venue? _parseVenue(dynamic v) {
    if (v is Map<String, dynamic>) return Venue.fromJson(v);
    return null;
  }

  factory EventItem.fromJson(Map<String, dynamic> json) {
    final orgVal = json['organizerId'];
    final venueVal = json['venueId'];

    final organizer = _parseOrganizer(orgVal);
    final venue = _parseVenue(venueVal);

    final organizerId = (orgVal is String)
        ? orgVal
        : (orgVal is Map<String, dynamic> ? (orgVal['_id']?.toString() ?? '') : '');

    final venueId = (venueVal is String)
        ? venueVal
        : (venueVal is Map<String, dynamic> ? (venueVal['_id']?.toString() ?? '') : '');

    return EventItem(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? '',
      capacity: (json['capacity'] is num) ? (json['capacity'] as num).toInt() : 0,
      eventDate: DateTime.tryParse(json['eventDate']?.toString() ?? '') ?? DateTime.now(),
      isPublic: json['isPublic'] == true,
      tags: (json['tags'] is List) ? (json['tags'] as List).map((e) => e.toString()).toList() : <String>[],
      extraInfo: (json['extraInfo'] is Map<String, dynamic>) ? (json['extraInfo'] as Map<String, dynamic>) : <String, dynamic>{},
      contactEmail: json['contactEmail']?.toString() ?? '',
      organizerId: organizerId,
      organizer: organizer,
      venueId: venueId,
      venue: venue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'eventType': eventType,
      'capacity': capacity,
      'eventDate': eventDate.toIso8601String(),
      'isPublic': isPublic,
      'tags': tags,
      'extraInfo': extraInfo,
      'contactEmail': contactEmail,
      'organizerId': organizerId,
      'venueId': venueId,
    };
  }
}
