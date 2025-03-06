import 'package:flutter/material.dart';
import '../../services/kakao_location_service.dart';

class SearchAddressModal extends StatefulWidget {
  final Function(String) onSelectAddress;

  const SearchAddressModal({super.key, required this.onSelectAddress});

  @override
  _SearchAddressModalState createState() => _SearchAddressModalState();
}

class _SearchAddressModalState extends State<SearchAddressModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _addressList = [];
  bool _isLoading = false;

  Future<void> _searchAddress() async {
    setState(() => _isLoading = true);
    try {
      final results =
          await KakaoLocationService.getAddress(_searchController.text);
      setState(() => _addressList = results);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("주소 검색 실패")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("주소 검색",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          // 검색 입력창
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "주소를 입력하세요.",
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: _searchAddress,
              ),
            ),
            onSubmitted: (_) => _searchAddress(),
          ),

          const SizedBox(height: 16),

          // 검색 결과
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _addressList.isEmpty
                  ? Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "입력 예시",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _buildExampleAddress(
                            "도로명 + 건물번호",
                            "남대문로 9길 40",
                          ),
                          _buildExampleAddress(
                            "지역명(동/리) + 번지",
                            "중구 다동 155",
                          ),
                          _buildExampleAddress(
                            "지역명(동/리)+ 건물명",
                            "분당 주공",
                          ),
                        ],
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _addressList.length,
                        itemBuilder: (context, index) {
                          final address = _addressList[index];
                          return ListTile(
                            title: Text(address["address_name"]),
                            subtitle: Text(address["place_name"] ?? ""),
                            onTap: () {
                              widget.onSelectAddress(address["address_name"]);
                            },
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildExampleAddress(String title, String example) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            example,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
