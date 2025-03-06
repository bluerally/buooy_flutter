import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
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
  Map<String, dynamic> selectedSport = {'id': 1, 'name': '프리다이빙'};
  String selectedAddress = "";
  int selectedParticipantCount = 2;
  String title = '';
  String description = '';
  String notice = '';
  bool _submitted = false;

  final List<Map<String, dynamic>> SPORTS = [
    {"id": 1, "name": "프리다이빙"},
    {"id": 2, "name": "스쿠버다이빙"},
    {"id": 3, "name": "서핑"},
    {"id": 4, "name": "수영"},
  ];

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

  Future<void> _createParty() async {
    setState(() {
      _submitted = true; // 게시하기 버튼 클릭 시 submitted 상태를 true로 설정
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // 추가 필드 검증
    if (selectedDate == null ||
        selectedTime == null ||
        selectedAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('모든 필수 항목을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(AppConfig.createPartyEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'body': description,
          'gather_date': DateFormat('yyyy-MM-dd').format(selectedDate!),
          'gather_time': selectedTime,
          'address': selectedAddress,
          'participant_limit': selectedParticipantCount,
          'sport_id': selectedSport['id'],
          'notice': notice,
        }),
      );

      if (response.statusCode == 201) {
        // 성공적으로 생성됨
        Navigator.pop(context); // 이전 화면으로 돌아가기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('모임이 성공적으로 생성되었습니다.')),
        );
      } else {
        // 에러 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('모임 생성에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      // 네트워크 에러 등 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    selectedSport = SPORTS[0];
    selectedParticipantCount = 2;
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
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: SPORTS.map((sport) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(sport['name']),
                          selected: selectedSport['id'] == sport['id'],
                          onSelected: (selected) {
                            setState(() {
                              selectedSport = selected ? sport : SPORTS[0];
                            });
                            print(selectedSport);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16),
                _buildSectionTitle('모임 날짜'),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: '날짜 선택',
                    errorText: _submitted && selectedDate == null
                        ? '모임 날짜를 선택해주세요'
                        : null,
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '필수 입력 항목입니다';
                    }
                    return null;
                  },
                  controller: TextEditingController(
                    text: selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                        : '',
                  ),
                ),
                SizedBox(height: 16),
                _buildSectionTitle('모임 시작 시간'),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: selectedTime ?? '',
                  ),
                  decoration: InputDecoration(
                    hintText: '시간 선택',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: 12, minute: 0),
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            alwaysUse24HourFormat: true,
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (picked != null) {
                      setState(() {
                        selectedTime =
                            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '모임 시간을 선택해주세요';
                    }
                    return null;
                  },
                ),
                // 유효성 검사 추가
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
                  decoration: InputDecoration(
                      hintText:
                          '프리다이빙 경력, 선호하는 다이빙 스팟, 보유한 장비, 관심 있는 기술 등을 알려주세요.'),
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
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: selectedAddress,
                  ),
                  decoration: InputDecoration(
                    hintText: '장소 선택',
                    suffixIcon: Icon(Icons.location_on),
                  ),
                  onTap: () => _showLocationPickerModal(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '모임 장소를 선택해주세요';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildSectionTitle('추가정보'),
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                      hintText:
                          '해당 정보는 모임을 신청한 멤버에게만 공개됩니다. 연락처, 오픈카톡 링크, 금액 등을 입력할 수 있어요.'),
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
              _createParty();
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
