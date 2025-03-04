class TokenModel {
  final String accessToken;
  final String refreshToken;
  final bool isNewUser;

  TokenModel({
    required this.accessToken,
    required this.refreshToken,
    this.isNewUser = false,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      isNewUser: json['is_new_user'] == 1 || json['is_new_user'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'is_new_user': isNewUser,
    };
  }
}
