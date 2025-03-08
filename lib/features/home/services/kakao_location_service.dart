import 'dart:convert';
import 'package:http/http.dart' as http;

class KakaoLocationService {
  static const String baseUrl =
      "https://dapi.kakao.com/v2/local/search/keyword.json";
  static const String apiKey = "5837f6242278d23d1a3455c5dea2a1ab";

  static Future<List<Map<String, dynamic>>> getLocation(String query) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl?query=$query"),
        headers: {"Authorization": "KakaoAK $apiKey"},
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonList = json.decode(decodedBody);

        return List<Map<String, dynamic>>.from(jsonList["documents"]);
      } else {
        throw Exception('주소 검색 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('주소 검색 실패: $e');
    }
  }
}
