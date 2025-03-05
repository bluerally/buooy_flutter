import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../models/sports_model.dart';
import './widgets/search_address_modal.dart';

class CreateGatheringScreen extends StatefulWidget {
  const CreateGatheringScreen({super.key});

  @override
  _CreateGatheringScreenState createState() => _CreateGatheringScreenState();
}

class _CreateGatheringScreenState extends State<CreateGatheringScreen> {
  final _formKey = GlobalKey<FormState>(); // FormKey 추가
  DateTime? selectedDate;
  String? selectedTime;
  String selectedSport = '프리다이빙'; // 기본값 설정
  String selectedAddress = "";
  int selectedParticipantCount = 2; // 기본값 설정
  String title = '';
  String description = '';
  String notice = '';

  final List<Map<String, dynamic>> PARTICIPANT_COUNT =
      List.generate(29, (i) => {'value': i + 2, 'title': '${i + 2}명'});

  List<String> _generateTimeList() {
    List<String> times = [];
    for (int hour = 8; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        String formattedHour = hour.toString().padLeft(2, '0');
        String formattedMinute = minute.toString().padLeft(2, '0');
        times.add('$formattedHour:$formattedMinute');
      }
    }
    return times;
  }

  void _showLocationPickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: 600,
            child: SearchAddressModal(
              onSelectAddress: (address) {
                setState(() {
                  selectedAddress = address;
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _onBackPressed(BuildContext context) async {
    List<dynamic> fields = [
      selectedDate,
      selectedTime,
      selectedSport,
      selectedAddress,
      selectedParticipantCount,
      title,
      description,
      notice,
    ];

    bool hasContent = fields.any((field) {
      if (field is String) {
        return field.isNotEmpty;
      }

      return field != null;
    });

    if (hasContent) {
      bool shouldExit = false;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('작업을 저장하지 않고 나가시겠어요?'),
            content: Text('모임 개설을 취소하고 뒤로 가시겠습니까?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('아니요'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 모달 닫기
                  Navigator.of(context).pop(); // 화면 뒤로가기
                },
                child: Text('예'),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    selectedSport = '프리다이빙'; // 기본값 설정
    selectedParticipantCount = 2; // 기본값 설정
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            _onBackPressed(context);
          },
        ),
        title: Text('모임 개설'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            // Form 위젯으로 감싸서 관리
            key: _formKey, // FormKey 추가
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('스포츠'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // 가로 스크롤 활성화
                  child: Row(
                    children: ['프리다이빙', '스쿠버다이빙', '수영', '서핑'].map((sport) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0), // 간격 추가
                        child: ChoiceChip(
                          label: Text(sport),
                          selected: selectedSport == sport,
                          onSelected: (selected) {
                            setState(() {
                              selectedSport = selected ? sport : '프리다이빙';
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
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
                // 유효성 검사 추가
                TextFormField(
                  initialValue: selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                      : '',
                  validator: (value) {
                    if (selectedDate == null) {
                      return '필수 입력 항목입니다';
                    }
                    return null;
                  },
                  style: TextStyle(color: Colors.transparent),
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
                  items: _generateTimeList().map((time) {
                    return DropdownMenuItem(
                      value: time,
                      child: Text(time),
                    );
                  }).toList(),
                ),
                // 유효성 검사 추가
                TextFormField(
                  initialValue: selectedTime ?? '',
                  validator: (value) {
                    if (selectedTime == null) {
                      return '필수 입력 항목입니다';
                    }
                    return null;
                  },
                  style: TextStyle(color: Colors.transparent),
                ),
                SizedBox(height: 16),
                _buildSectionTitle('참여 인원수'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // 가로 스크롤 활성화
                  child: Row(
                    children: PARTICIPANT_COUNT.map((participant) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.0), // 간격 조정
                        child: ChoiceChip(
                          label: Text(participant['title']),
                          selected:
                              selectedParticipantCount == participant['value'],
                          onSelected: (selected) {
                            setState(() {
                              selectedParticipantCount =
                                  selected ? participant['value'] : null;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16),
                _buildSectionTitle('제목'),
                TextFormField(
                  decoration: InputDecoration(hintText: '제목을 입력해주세요'),
                  onChanged: (value) {
                    setState(() {
                      title = value;
                    });
                    // 입력을 시작하면 error 메시지 제거
                    _formKey.currentState?.validate();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '필수 입력 항목입니다';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildSectionTitle('내용'),
                TextFormField(
                  maxLines: 4,
                  decoration: InputDecoration(hintText: '내용을 입력해주세요'),
                  onChanged: (value) {
                    setState(() {
                      description = value;
                    });
                    // 입력을 시작하면 error 메시지 제거
                    _formKey.currentState?.validate();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '필수 입력 항목입니다';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildSectionTitle('장소'),
                ListTile(
                  title: Text(
                      selectedAddress.isNotEmpty ? selectedAddress : '장소 선택'),
                  trailing: Icon(Icons.location_on),
                  onTap: () => _showLocationPickerModal(context),
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
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              // 게시하기 로직
            }
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
