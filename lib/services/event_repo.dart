import '../models/event.dart';
import 'api_client.dart';

class EventRepo {
  Future<List<EventItem>> list({
    String? eventType,
    bool? isPublic,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final q = <String, String>{};
    if (eventType != null && eventType.isNotEmpty) q['eventType'] = eventType;
    if (isPublic != null) q['isPublic'] = isPublic.toString();
    if (fromDate != null) q['fromDate'] = fromDate.toIso8601String().substring(0, 10);
    if (toDate != null) q['toDate'] = toDate.toIso8601String().substring(0, 10);

    final arr = await ApiClient.getList('/events', query: q.isEmpty ? null : q);
    return arr.map((e) => EventItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<EventItem> create(EventItem item) async {
    final j = await ApiClient.post('/events', item.toJson());
    return EventItem.fromJson(j);
  }

  Future<EventItem> update(String id, EventItem item) async {
    final j = await ApiClient.put('/events/$id', item.toJson());
    return EventItem.fromJson(j);
  }

  Future<List<Map<String, dynamic>>> aggregate() async {
    final arr = await ApiClient.getList('/events-aggregate');
    return arr.map((e) => e as Map<String, dynamic>).toList();
  }
}
