enum Environment { local, prod }

class AppConfig {
  static Environment environment = Environment.local;

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.local:
        return 'http://localhost:8000/api';
      case Environment.prod:
        return 'https://3.36.234.165.nip.io/api';
    }
  }

  // API Endpoints

  // static String get partyListEndpoint => '$apiBaseUrl/party/list';
  static String get partyListEndpoint =>
      'https://3.36.234.165.nip.io/api/party/list';

  static String get sportsListEndpoint =>
      'https://3.36.234.165.nip.io/api/party/sports';

  // 다른 API 엔드포인트들도 여기에 추가할 수 있습니다.
  // static String get userProfileEndpoint => '$apiBaseUrl/user/profile';
  // static String get authEndpoint => '$apiBaseUrl/auth';
  // 등등...
}
