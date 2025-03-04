class ApiConstants {
  static const String baseUrl =
      'https://api.example.com'; // 실제 API 서버 주소로 변경 필요

  // Auth endpoints
  static const String redirectUrl = '$baseUrl/api/user/auth/redirect-url';
  static const String loginCallback = '$baseUrl/api/user/auth';
  static const String tokenRefresh = '$baseUrl/api/user/auth/token/refresh';
  static const String logout = '$baseUrl/api/user/auth/logout';

  // Social login platforms
  static const String platformGoogle = 'google';
  static const String platformKakao = 'kakao';
  static const String platformNaver = 'naver';

  // SDK 설정
  static const String kakaoNativeAppKey =
      '{NATIVE_APP_KEY}'; // 카카오 네이티브 앱키로 변경 필요
  static const String naverClientId =
      '{NAVER_CLIENT_ID}'; // 네이버 클라이언트 ID로 변경 필요
  static const String naverClientSecret =
      '{NAVER_CLIENT_SECRET}'; // 네이버 클라이언트 시크릿으로 변경 필요
}
