import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../models/sports_model.dart';

class CreateGatheringScreen extends StatefulWidget {
  const CreateGatheringScreen({super.key});

  @override
  _CreateGatheringScreenState createState() => _CreateGatheringScreenState();
}

class _CreateGatheringScreenState extends State<CreateGatheringScreen> {
  DateTime? selectedDate;
  String? selectedTime;
  String? selectedSport;
  int? selectedParticipant;
  int? selectedParticipantCount;
  String title = '';
  String description = '';
  String address = '';
  String placeName = '';
  String notice = '';
  List<dynamic> sports = [];

  // 인원수 리스트 생성 (2명부터 30명까지)
  final List<Map<String, dynamic>> PARTICIPANT_COUNT =
      List.generate(29, (i) => {'value': i + 2, 'title': '${i + 2}명'});

  @override
  void initState() {
    super.initState();
    fetchSports();
  }

  Future<void> fetchSports() async {
    final uri = Uri.parse(AppConfig.sportsListEndpoint);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);

        setState(() {
          sports = data.map((json) => Sport.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Failed to load sports: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            // Confirm close logic
          },
        ),
        title: Text('모임 개설'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('스포츠'),
              Wrap(
                spacing: 8.0,
                children: sports.map((sport) {
                  return ChoiceChip(
                    label: Text(sport.name),
                    selected: selectedSport == sport,
                    onSelected: (selected) {
                      setState(() {
                        selectedSport = selected ? sport : null;
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              _buildSectionTitle('모임 날짜'),
              ListTile(
                title: Text(selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                    : '날짜 선택'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              _buildSectionTitle('모임 시작 시간'),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedTime,
                hint: Text('00:00'),
                onChanged: (value) {
                  setState(() {
                    selectedTime = value;
                  });
                },
                items: ['10:00', '11:00'].map((time) {
                  return DropdownMenuItem(
                    value: time,
                    child: Text(time),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              _buildSectionTitle('참여 인원수'),
              Wrap(
                spacing: 8.0,
                children: PARTICIPANT_COUNT.map((participant) {
                  return ChoiceChip(
                    label: Text(participant['title']),
                    selected: selectedParticipant == participant['value'],
                    onSelected: (selected) {
                      setState(() {
                        selectedParticipant =
                            selected ? participant['value'] : null;
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              _buildSectionTitle('제목'),
              TextField(
                decoration: InputDecoration(hintText: '제목을 입력해주세요'),
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
              ),
              SizedBox(height: 16),
              _buildSectionTitle('내용'),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(hintText: '내용을 입력해주세요'),
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
              ),
              SizedBox(height: 16),
              _buildSectionTitle('장소'),
              ListTile(
                title: Text(address.isNotEmpty ? address : '장소 선택'),
                trailing: Icon(Icons.location_on),
                onTap: () {
                  // 장소 선택 로직
                },
              ),
              SizedBox(height: 16),
              _buildSectionTitle('추가 정보'),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(hintText: '추가 정보를 입력해주세요'),
                onChanged: (value) {
                  setState(() {
                    notice = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // 게시하기 로직
          },
          child: Text('게시하기'),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
