import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  DioClient._();

  static VoidCallback? onUnauthorized;
  static bool _isRefreshing = false;
  static final List<Completer<String>> _queue = [];
  static const _storage = FlutterSecureStorage();

  static Dio get instance => _dio;

  // JWT payload에서 만료 5분 전 여부 체크
  static bool _isExpiringSoon(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = json['exp'] as int?;
      if (exp == null) return false;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return expiry.isBefore(DateTime.now().add(const Duration(minutes: 5)));
    } catch (_) {
      return false;
    }
  }

  static Future<String?> _doRefresh() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return null;

    final refreshResponse = await Dio().post(
      '${dotenv.env['BASE_URL'] ?? 'http://localhost:8080'}/api/auth/refresh',
      options: Options(headers: {
        'Authorization': 'Bearer $refreshToken',
        'Content-Type': 'application/json',
      }),
    );

    final newAccessToken =
        refreshResponse.data['data']['accessToken'] as String;
    final newRefreshToken =
        refreshResponse.data['data']['refreshToken'] as String?;
    await _storage.write(key: 'accessToken', value: newAccessToken);
    if (newRefreshToken != null) {
      await _storage.write(key: 'refreshToken', value: newRefreshToken);
    }
    return newAccessToken;
  }

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? 'http://localhost:8080',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(InterceptorsWrapper(
      // ── 요청 전: 만료 5분 전이면 미리 refresh ──
      onRequest: (options, handler) async {
        final authHeader = options.headers['Authorization'] as String?;
        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return handler.next(options);
        }

        final token = authHeader.substring(7);
        if (!_isExpiringSoon(token)) return handler.next(options);

        if (_isRefreshing) {
          final completer = Completer<String>();
          _queue.add(completer);
          try {
            final newToken = await completer.future;
            options.headers['Authorization'] = 'Bearer $newToken';
          } catch (_) {}
          return handler.next(options);
        }

        _isRefreshing = true;
        try {
          final newToken = await _doRefresh();
          if (newToken != null) {
            _resolveQueue(newToken);
            options.headers['Authorization'] = 'Bearer $newToken';
          }
        } catch (_) {
          _clearQueue();
        } finally {
          _isRefreshing = false;
        }

        return handler.next(options);
      },

      // ── 401 응답: 안전망 ──
      onError: (error, handler) async {
        if (error.response?.statusCode != 401) {
          return handler.next(error);
        }

        if (_isRefreshing) {
          final completer = Completer<String>();
          _queue.add(completer);
          try {
            final newToken = await completer.future;
            error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final retryResponse = await _dio.fetch(error.requestOptions);
            return handler.resolve(retryResponse);
          } catch (_) {
            return handler.next(error);
          }
        }

        _isRefreshing = true;

        try {
          final refreshToken = await _storage.read(key: 'refreshToken');

          if (refreshToken == null) {
            _rejectQueue(error);
            onUnauthorized?.call();
            return handler.next(error);
          }

          final newAccessToken = await _doRefresh();
          if (newAccessToken == null) throw Exception();

          _resolveQueue(newAccessToken);

          error.requestOptions.headers['Authorization'] =
              'Bearer $newAccessToken';
          final retryResponse = await _dio.fetch(error.requestOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          _rejectQueue(error);
          await _storage.deleteAll();
          onUnauthorized?.call();
          return handler.next(error);
        } finally {
          _isRefreshing = false;
        }
      },
    ));

  static void _resolveQueue(String token) {
    for (final c in _queue) {
      c.complete(token);
    }
    _queue.clear();
  }

  static void _rejectQueue(DioException error) {
    for (final c in _queue) {
      c.completeError(error);
    }
    _queue.clear();
  }

  static void _clearQueue() {
    for (final c in _queue) {
      c.completeError('refresh_failed');
    }
    _queue.clear();
  }

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
