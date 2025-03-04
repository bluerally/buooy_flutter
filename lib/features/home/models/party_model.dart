class UserSimpleProfile {
  final int id;
  final String nickname;
  final String? profileImage;

  UserSimpleProfile({
    required this.id,
    required this.nickname,
    this.profileImage,
  });

  factory UserSimpleProfile.fromJson(Map<String, dynamic> json) {
    return UserSimpleProfile(
      id: json['user_id'], // 백엔드: user_id
      nickname: json['name'], // 백엔드: name
      profileImage: json['profile_picture'], // 백엔드: profile_picture
    );
  }
}

class PartyListDetail {
  final int id;
  final String title;
  final String sportName;
  final String gatherDate;
  final String gatherTime;
  final int price;
  final String body;
  final UserSimpleProfile organizerProfile;
  final String postedDate;
  final bool isActive;
  final String participantsInfo;
  final bool isUserOrganizer;
  final String placeName;
  final int? placeId;
  final String address;
  final double longitude;
  final double latitude;

  PartyListDetail({
    required this.id,
    required this.title,
    required this.sportName,
    required this.gatherDate,
    required this.gatherTime,
    required this.price,
    required this.body,
    required this.organizerProfile,
    required this.postedDate,
    required this.isActive,
    required this.participantsInfo,
    required this.isUserOrganizer,
    required this.placeName,
    this.placeId,
    required this.address,
    required this.longitude,
    required this.latitude,
  });

  factory PartyListDetail.fromJson(Map<String, dynamic> json) {
    return PartyListDetail(
      id: json['id'],
      title: json['title'],
      sportName: json['sport_name'],
      gatherDate: json['gather_date'],
      gatherTime: json['gather_time'],
      price: json['price'],
      body: json['body'],
      organizerProfile: UserSimpleProfile.fromJson(json['organizer_profile']),
      postedDate: json['posted_date'],
      isActive: json['is_active'],
      participantsInfo: json['participants_info'],
      isUserOrganizer: json['is_user_organizer'],
      placeName: json['place_name'],
      placeId: json['place_id'],
      address: json['address'],
      longitude: json['longitude'],
      latitude: json['latitude'],
    );
  }
}
