import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/photo_models.dart';

class PhotoService {
  static const String _baseUrl = 'https://picsum.photos/v2';

  Future<List<InspirationPhoto>> fetchInspirationPhotos({int limit = 5}) async {
    final uri = Uri.parse('$_baseUrl/list?limit=$limit');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map(
            (item) => InspirationPhoto.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception('Failed to load inspiration photos');
    }
  }
}
