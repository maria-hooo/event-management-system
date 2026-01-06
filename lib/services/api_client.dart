import 'dart:convert';
import 'package:http/http.dart' as http;

/// Central place to change base URL.
/// If you run on Android emulator, use: http://10.0.2.2:3000
/// If you run on iOS simulator, use: http://127.0.0.1:3000
/// If you run on web, use: http://localhost:3000
class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static Uri uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('$baseUrl$path').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  static Future<dynamic> getJson(Uri url) async {
    final res = await http.get(url);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('GET $url failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body);
  }

  static Future<dynamic> postJson(Uri url, Map<String, dynamic> body) async {
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('POST $url failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body);
  }

  static Future<dynamic> putJson(Uri url, Map<String, dynamic> body) async {
    final res = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('PUT $url failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body);
  }

  static Future<dynamic> patchJson(Uri url, Map<String, dynamic> body) async {
    final res = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('PATCH $url failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body);
  }

  static Future<void> deleteJson(Uri url) async {
    final res = await http.delete(url);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('DELETE $url failed: ${res.statusCode} ${res.body}');
    }
  }
}
