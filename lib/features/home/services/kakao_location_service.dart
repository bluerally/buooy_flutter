import 'dart:convert';
import 'package:http/http.dart' as http;

class KakaoLocationService {
  static const String baseUrl =
      "https://dapi.kakao.com/v2/local/search/keyword.json";
  static const String apiKey = "579d9cad96a609dbe9b1c3711ebd7b67";

  static Future<List<Map<String, dynamic>>> getAddress(String query) async {
    final response = await http.get(
      Uri.parse("$baseUrl?query=$query"),
      headers: {"Authorization": "KakaoAK $apiKey"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data["documents"]);
    } else {
      throw Exception("주소 검색 실패");
    }
  }
}
