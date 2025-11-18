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

  // 카카오 로그인 토큰을 백엔드로 전송
  Future<TokenResponse> loginWithKakao(String accessToken) async {
    try {
      final response = await _dio.post(
        ApiConfig.kakaoLoginUrl,
        data: {
          'accessToken': accessToken,
        },
      );

      return TokenResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 구글 로그인 토큰을 백엔드로 전송
  Future<TokenResponse> loginWithGoogle(String accessToken) async {
    try {
      final response = await _dio.post(
        ApiConfig.googleLoginUrl,
        data: {
          'accessToken': accessToken,
        },
      );

      return TokenResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 네이버 로그인 토큰을 백엔드로 전송
  Future<TokenResponse> loginWithNaver(String accessToken) async {
    try {
      final response = await _dio.post(
        ApiConfig.naverLoginUrl,
        data: {
          'accessToken': accessToken,
        },
      );

      return TokenResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? '로그인에 실패했습니다.';
    } else {
      return '네트워크 연결을 확인해주세요.';
    }
  }
}
