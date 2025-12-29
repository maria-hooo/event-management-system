import '../models/organizer.dart';
import 'api_client.dart';

class OrganizerRepo {
  Future<List<Organizer>> list() async {
    final arr = await ApiClient.getList('/organizers');
    return arr.map((e) => Organizer.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Organizer> create(String orgName, String phone) async {
    final j = await ApiClient.post('/organizers', {'orgName': orgName, 'phone': phone});
    return Organizer.fromJson(j);
  }

  Future<Organizer> update(String id, String orgName, String phone) async {
    final j = await ApiClient.put('/organizers/$id', {'orgName': orgName, 'phone': phone});
    return Organizer.fromJson(j);
  }
}
