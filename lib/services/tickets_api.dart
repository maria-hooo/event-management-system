import '../models/ticket_model.dart';
import 'api_client.dart';

class TicketsApi {
  static Future<List<TicketModel>> fetchAll() async {
    final data = await ApiClient.getJson(ApiClient.uri('/tickets'));
    return (data as List).map((e) => TicketModel.fromJson(e)).toList();
  }

  static Future<TicketModel> createTicket(Map<String, dynamic> body) async {
    final data = await ApiClient.postJson(ApiClient.uri('/tickets'), body);
    return TicketModel.fromJson(data as Map<String, dynamic>);
  }

  static Future<TicketModel> updateTicket(String id, Map<String, dynamic> body) async {
    final data = await ApiClient.putJson(ApiClient.uri('/tickets/$id'), body);
    return TicketModel.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deleteTicket(String id) async {
    await ApiClient.deleteJson(ApiClient.uri('/tickets/$id'));
  }
}
