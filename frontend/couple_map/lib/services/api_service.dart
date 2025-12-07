import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/auth/login_token_response.dart';
import '../models/auth/nickname_request.dart';
import '../models/auth/nickname_response.dart';
import '../models/auth/user_info.dart';
import '../models/map/map_list.dart';
import '../models/friend/friend_info.dart';
import '../models/friend/friend_pending_info.dart';
import '../models/map/create_map_request.dart';
import '../models/friend/send_friend_request.dart';
import '../models/memory/memory_list.dart';
import '../models/memory/memory_detail.dart';
import '../models/memory/create_memory_request.dart';

class ApiService {
  final Dio _dio;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  // 공통 로그인 메서드
  Future<LoginTokenResponse> _loginWithProvider(
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

      return LoginTokenResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 카카오 로그인
  Future<LoginTokenResponse> loginWithKakao(String accessToken) async {
    return _loginWithProvider(ApiConfig.kakaoLoginUrl, accessToken);
  }

  // 구글 로그인
  Future<LoginTokenResponse> loginWithGoogle(String accessToken) async {
    return _loginWithProvider(ApiConfig.googleLoginUrl, accessToken);
  }

  // 네이버 로그인
  Future<LoginTokenResponse> loginWithNaver(String accessToken) async {
    return _loginWithProvider(ApiConfig.naverLoginUrl, accessToken);
  }

  // 닉네임 설정
  Future<NicknameResponse> setNickname(
    String accessToken,
    String nickname,
  ) async {
    try {
      final response = await _dio.post(
        ApiConfig.setNicknameUrl,
        data: NicknameRequest(nickname: nickname).toJson(),
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data['data'];
      if (data == null) {
        throw Exception('응답 데이터가 없습니다.');
      }

      return NicknameResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 내 정보 조회
  Future<UserInfo> getUserInfo(String accessToken) async {
    try {
      final response = await _dio.get(
        ApiConfig.getUserInfoUrl,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data['data'];
      if (data == null) {
        throw Exception('응답 데이터가 없습니다.');
      }

      return UserInfo.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 지도 목록 조회
  Future<List<MapList>> getMapList(String accessToken) async {
    try {
      final response = await _dio.get(
        ApiConfig.getMapListUrl,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data['data'] as List;
      return data.map((json) => MapList.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 지도 생성
  Future<int> createMap(
    String accessToken,
    String mapName,
    String? description,
  ) async {
    try {
      final response = await _dio.post(
        ApiConfig.createMapUrl,
        data: CreateMapRequest(
          mapName: mapName,
          description: description,
        ).toJson(),
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data['data'];
      if (data == null) {
        throw Exception('응답 데이터가 없습니다.');
      }

      return data as int;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 친구 목록 조회
  Future<List<FriendInfo>> getFriendList(String accessToken) async {
    try {
      final response = await _dio.get(
        ApiConfig.getFriendListUrl,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data['data']['friendList'] as List;
      return data.map((json) => FriendInfo.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 대기 중인 친구 요청 조회
  Future<List<FriendPendingInfo>> getPendingFriendList(
    String accessToken,
  ) async {
    try {
      final response = await _dio.get(
        ApiConfig.getPendingFriendListUrl,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data['data']['friendPendingInfoDtoList'] as List;
      return data.map((json) => FriendPendingInfo.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 친구 요청 전송
  Future<void> sendFriendRequest(String accessToken, String friendCode) async {
    try {
      await _dio.post(
        ApiConfig.sendFriendRequestUrl,
        data: SendFriendRequest(friendCode: friendCode).toJson(),
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 친구 요청 수락
  Future<void> acceptFriendRequest(String accessToken, int friendshipId) async {
    try {
      await _dio.post(
        ApiConfig.acceptFriendRequestUrl(friendshipId),
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 친구 요청 거절
  Future<void> rejectFriendRequest(String accessToken, int friendshipId) async {
    try {
      await _dio.post(
        ApiConfig.rejectFriendRequestUrl(friendshipId),
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 로그아웃
  Future<void> logout(String accessToken) async {
    try {
      await _dio.post(
        ApiConfig.logoutUrl,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 추억 목록 조회
  Future<List<MemoryList>> getMemoryList(
    String accessToken,
    int mapId,
  ) async {
    try {
      final response = await _dio.get(
        ApiConfig.getMemoryListUrl(mapId),
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data['data'];
      if (data == null) {
        return [];
      }

      if (data is! List) {
        throw Exception('응답 형식이 올바르지 않습니다. 받은 데이터: $data');
      }

      return data.map((json) => MemoryList.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e, stackTrace) {
      print('추억 목록 파싱 에러: $e');
      print('StackTrace: $stackTrace');
      rethrow;
    }
  }

  // 추억 생성 (이미지 업로드 포함)
  Future<int> createMemory(
    String accessToken,
    int mapId,
    CreateMemoryRequest request,
    List<File>? imageFiles,
  ) async {
    try {
      final formData = FormData();

      // JSON 데이터를 Blob으로 추가
      formData.files.add(MapEntry(
        'request',
        MultipartFile.fromString(
          request.toJsonString(),
          contentType: DioMediaType.parse('application/json'),
        ),
      ));

      // 이미지 파일 추가
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (var file in imageFiles) {
          formData.files.add(MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ));
        }
      }

      final response = await _dio.post(
        ApiConfig.createMemoryUrl(mapId),
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final data = response.data['data'];
      if (data == null) {
        throw Exception('응답 데이터가 없습니다.');
      }

      return data as int;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? '요청에 실패했습니다.';
    } else {
      return '네트워크 연결을 확인해주세요.';
    }
  }
}
