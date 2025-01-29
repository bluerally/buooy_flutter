enum Environment { dev, staging, prod }

class AppConfig {
  static Environment environment = Environment.dev;

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'https://dev.3.36.234.165.nip.io/api';
      case Environment.staging:
        return 'https://staging.3.36.234.165.nip.io/api';
      case Environment.prod:
        return 'https://3.36.234.165.nip.io/api';
    }
  }

  // API Endpoints
  static String get partyListEndpoint => '$apiBaseUrl/party/list';

  // 다른 API 엔드포인트들도 여기에 추가할 수 있습니다.
  // static String get userProfileEndpoint => '$apiBaseUrl/user/profile';
  // static String get authEndpoint => '$apiBaseUrl/auth';
  // 등등...
}
