import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/party_model.dart';
import '../../../core/config/app_config.dart';

class PartyService {
  Future<List<PartyListDetail>> getPartyList({
    List<int>? sportId,
    bool? isActive,
    String? gatherDateMin,
    String? gatherDateMax,
    String? searchQuery,
    required int page,
  }) async {
    final queryParameters = {
      if (sportId != null) 'sport_id': sportId.join(','),
      if (isActive != null) 'is_active': isActive.toString(),
      if (gatherDateMin != null) 'gather_date_min': gatherDateMin,
      if (gatherDateMax != null) 'gather_date_max': gatherDateMax,
      if (searchQuery != null) 'search_query': searchQuery,
      'page': page.toString(),
    };

    final uri = Uri.parse(AppConfig.partyListEndpoint)
        .replace(queryParameters: queryParameters);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonList = json.decode(decodedBody);
        return jsonList.map((json) => PartyListDetail.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load party list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load party list: $e');
    }
  }
}
