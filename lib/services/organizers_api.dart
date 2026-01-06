import '../models/organizer.dart';
import 'api_client.dart';

class OrganizersApi {
  static Future<List<Organizer>> fetchAll() async {
    final data = await ApiClient.getJson(ApiClient.uri('/organizers'));
    return (data as List).map((e) => Organizer.fromJson(e)).toList();
  }

  static Future<Organizer> create(Map<String, dynamic> body) async {
    final data = await ApiClient.postJson(ApiClient.uri('/organizers'), body);
    return Organizer.fromJson(data as Map<String, dynamic>);
  }

  static Future<Organizer> update(String id, Map<String, dynamic> body) async {
    final data = await ApiClient.putJson(ApiClient.uri('/organizers/$id'), body);
    return Organizer.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> delete(String id) async {
    await ApiClient.deleteJson(ApiClient.uri('/organizers/$id'));
  }
}
