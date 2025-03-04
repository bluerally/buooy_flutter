class UserModel {
  final int? id;
  final String? snsId;
  final String? email;
  final String? name;
  final String? profileImage;
  final String? introduction;
  final bool isLoggedIn;

  UserModel({
    this.id,
    this.snsId,
    this.email,
    this.name,
    this.profileImage,
    this.introduction,
    this.isLoggedIn = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      snsId: json['sns_id'],
      email: json['email'],
      name: json['name'],
      profileImage: json['profile_image'],
      introduction: json['introduction'],
      isLoggedIn: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sns_id': snsId,
      'email': email,
      'name': name,
      'profile_image': profileImage,
      'introduction': introduction,
    };
  }

  UserModel copyWith({
    int? id,
    String? snsId,
    String? email,
    String? name,
    String? profileImage,
    String? introduction,
    bool? isLoggedIn,
  }) {
    return UserModel(
      id: id ?? this.id,
      snsId: snsId ?? this.snsId,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      introduction: introduction ?? this.introduction,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}
