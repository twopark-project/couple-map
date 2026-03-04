import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  DioClient._();

  static Dio get instance => _dio;

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? 'http://localhost:8080',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static String handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'];
      return message?.toString() ?? '요청에 실패했습니다.';
    }
    return '네트워크 연결을 확인해주세요.';
  }

  static Options authOptions(String accessToken) => Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      );
}
