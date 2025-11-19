import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // 백엔드 서버 URL (.env 파일에서 읽음)
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

  // 소셜 로그인 엔드포인트
  static const String kakaoLoginUrl = '/api/login/social/kakao';
  static const String googleLoginUrl = '/api/login/social/google';
  static const String naverLoginUrl = '/api/login/social/naver';
}
