import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/party_model.dart';

class PartyCard extends StatelessWidget {
  final PartyListDetail party;

  const PartyCard({super.key, required this.party});

  @override
  Widget build(BuildContext context) {
    // gather_date + gather_time을 DateTime으로 파싱
    DateTime? gatherDateTime;
    try {
      // 예: "2024-02-03T08:00" 형태로 만들어 파싱
      gatherDateTime =
          DateTime.parse('${party.gatherDate}T${party.gatherTime}');
    } catch (_) {
      // 파싱 실패 시 null
    }

    // 원하는 포맷: "25.02.03 08:00" (dd.MM.yy HH:mm)
    final String formattedGatherDate = gatherDateTime != null
        ? DateFormat('dd.MM.yy HH:mm').format(gatherDateTime)
        : '${party.gatherDate} ${party.gatherTime}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) 상단: 종목 태그만 (post date 제거)
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    party.sportName,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 2) 제목
            Text(
              party.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // 3) 본문
            Text(
              party.body,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),

            // 4) 날짜, 인원수, 장소 (아이콘 추가)
            Row(
              children: [
                // 달력 아이콘 + 모임 날짜/시간
                const Icon(Icons.calendar_today, size: 14),
                const SizedBox(width: 4),
                Text(
                  formattedGatherDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 16),

                // 사람 아이콘 + 인원수
                const Icon(Icons.person, size: 14),
                const SizedBox(width: 4),
                Text(
                  party.participantsInfo,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 16),

                // 지도 아이콘 + 장소
                const Icon(Icons.location_on, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    party.placeName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 5) 프로필 사진 + 닉네임 (왼쪽)
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      (party.organizerProfile.profileImage != null &&
                              party.organizerProfile.profileImage!.isNotEmpty)
                          ? NetworkImage(party.organizerProfile.profileImage!)
                          : null,
                  radius: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  party.organizerProfile.nickname,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
