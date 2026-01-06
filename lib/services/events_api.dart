import '../models/event_model.dart';
import 'api_client.dart';

class EventsApi {
  static Future<List<EventModel>> fetchAll() async {
    final data = await ApiClient.getJson(ApiClient.uri('/events'));
    return (data as List).map((e) => EventModel.fromJson(e)).toList();
  }

  /// Two-criteria filter (category + isPublic)
  static Future<List<EventModel>> fetchFiltered({
    String? category,
    bool? isPublic,
  }) async {
    final query = <String, dynamic>{};
    if (category != null && category.isNotEmpty) query['category'] = category;
    if (isPublic != null) query['isPublic'] = isPublic;

    final data = await ApiClient.getJson(ApiClient.uri('/events/filter', query));
    return (data as List).map((e) => EventModel.fromJson(e)).toList();
  }

  static Future<EventModel> createEvent(Map<String, dynamic> body) async {
    final data = await ApiClient.postJson(ApiClient.uri('/events'), body);
    return EventModel.fromJson(data as Map<String, dynamic>);
  }

  /// Update event (full update)
  static Future<EventModel> updateEvent(String id, Map<String, dynamic> body) async {
    final data = await ApiClient.putJson(ApiClient.uri('/events/$id'), body);
    return EventModel.fromJson(data as Map<String, dynamic>);
  }

  /// Partial update (useful for updating time/startDate only)
  static Future<EventModel> patchEvent(String id, Map<String, dynamic> body) async {
    final data = await ApiClient.patchJson(ApiClient.uri('/events/$id'), body);
    return EventModel.fromJson(data as Map<String, dynamic>);
  }
}
