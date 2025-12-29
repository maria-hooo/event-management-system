import '../models/ticket.dart';
import 'api_client.dart';

class TicketRepo {
  Future<List<Ticket>> list({String? eventId}) async {
    final q = <String, String>{};
    if (eventId != null && eventId.isNotEmpty) q['eventId'] = eventId;

    final arr = await ApiClient.getList('/tickets', query: q.isEmpty ? null : q);
    return arr.map((e) => Ticket.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Ticket> create(Ticket t) async {
    final j = await ApiClient.post('/tickets', t.toJson());
    return Ticket.fromJson(j);
  }

  Future<Ticket> update(String id, Ticket t) async {
    final j = await ApiClient.put('/tickets/$id', t.toJson());
    return Ticket.fromJson(j);
  }

  Future<List<Map<String, dynamic>>> report() async {
    final arr = await ApiClient.getList('/tickets-report');
    return arr.map((e) => e as Map<String, dynamic>).toList();
  }
}
