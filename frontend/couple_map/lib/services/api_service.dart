import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/token_response.dart';

class ApiService {
  final Dio _dio;

  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

  // 공통 로그인 메서드
  Future<TokenResponse> _loginWithProvider(
    String endpoint,
    String accessToken,
  ) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: {'accessToken': accessToken},
      );
      
      final data = response.data['data'];
      if (data == null) {
        throw Exception('응답 데이터가 없습니다.');
      }
      
      return TokenResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 카카오 로그인
  Future<TokenResponse> loginWithKakao(String accessToken) async {
    return _loginWithProvider(ApiConfig.kakaoLoginUrl, accessToken);
  }

  // 구글 로그인
  Future<TokenResponse> loginWithGoogle(String accessToken) async {
    return _loginWithProvider(ApiConfig.googleLoginUrl, accessToken);
  }

  // 네이버 로그인
  Future<TokenResponse> loginWithNaver(String accessToken) async {
    return _loginWithProvider(ApiConfig.naverLoginUrl, accessToken);
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? '로그인에 실패했습니다.';
    } else {
      return '네트워크 연결을 확인해주세요.';
    }
  }
}
