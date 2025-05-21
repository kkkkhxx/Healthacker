import 'dart:convert';
import 'package:http/http.dart' as http;

class TomTomService {
  static const String _apiKey = 'SqRm4x62Fb7oJ7l8Wj0dJfdbRgAAOu5a'; // <- เปลี่ยนเป็น API Key ของคุณ
  static const String _baseUrl = 'https://api.tomtom.com/search/2/search';

  static Future<List<String>> searchLocations(String query) async {
    final url = Uri.parse('$_baseUrl/$query.json?key=$_apiKey&limit=5');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      return results.map((e) => e['address']['freeformAddress'] as String).toList();
    } else {
      throw Exception('Failed to load locations from TomTom');
    }
  }
}
