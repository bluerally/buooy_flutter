import 'package:flutter/material.dart';
import '../../models/party_model.dart';

class PartyCard extends StatelessWidget {
  final PartyListDetail party;

  const PartyCard({super.key, required this.party});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(party.sportName),
                ),
                const Spacer(),
                Text(party.postedDate),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              party.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(party.body),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text('${party.gatherDate} ${party.gatherTime}'),
                const SizedBox(width: 16),
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Expanded(child: Text(party.placeName)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: party.organizerProfile.profileImage != null
                      ? NetworkImage(party.organizerProfile.profileImage!)
                      : null,
                  radius: 16,
                ),
                const SizedBox(width: 8),
                Text(party.organizerProfile.nickname),
                const Spacer(),
                Text(party.participantsInfo),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
