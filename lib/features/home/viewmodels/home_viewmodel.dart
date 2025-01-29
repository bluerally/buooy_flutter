import 'package:flutter/material.dart';
import '../models/party_model.dart';
import '../services/party_service.dart';

class HomeViewModel extends ChangeNotifier {
  final PartyService _partyService = PartyService();
  List<PartyListDetail> parties = [];
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 1;

  Future<void> loadParties({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      parties.clear();
      hasMore = true;
      notifyListeners();
    }

    if (isLoading || !hasMore) return;

    isLoading = true;
    if (!refresh) notifyListeners();

    try {
      final newParties = await _partyService.getPartyList(page: currentPage);
      if (newParties.isEmpty) {
        hasMore = false;
      } else {
        parties.addAll(newParties);
        currentPage++;
      }
    } catch (e) {
      // Handle error
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 스크롤 이벤트를 처리하기 위한 메서드 추가
  void handleScrollWithLoadMore(ScrollController controller) {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      loadParties();
    }
  }
}
