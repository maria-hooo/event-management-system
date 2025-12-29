import '../models/venue.dart';
import 'api_client.dart';

class VenueRepo {
  Future<List<Venue>> list() async {
    final arr = await ApiClient.getList('/venues');
    return arr.map((e) => Venue.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Venue> create({
    required String name,
    required String address,
    required int capacityLimit,
    required Map<String, dynamic> locationJson,
  }) async {
    final j = await ApiClient.post('/venues', {
      'name': name,
      'address': address,
      'capacityLimit': capacityLimit,
      'locationJson': locationJson,
    });
    return Venue.fromJson(j);
  }

  Future<Venue> update({
    required String id,
    required String name,
    required String address,
    required int capacityLimit,
    required Map<String, dynamic> locationJson,
  }) async {
    final j = await ApiClient.put('/venues/$id', {
      'name': name,
      'address': address,
      'capacityLimit': capacityLimit,
      'locationJson': locationJson,
    });
    return Venue.fromJson(j);
  }
}
