import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/map_model.dart';

class MapRepository {
  // 지도 초대 목록 조회
  Future<List<MapInvitation>> getMapInvitations(String accessToken) async {
    try {
      final response = await DioClient.instance.get(
        '/api/map/invitations',
        options: DioClient.authOptions(accessToken),
      );
      final data = response.data['data'] as List;
      return data.map((json) => MapInvitation.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // 친구를 지도에 초대
  Future<void> inviteFriendToMap(String accessToken, int mapId, int friendId) async {
    try {
      await DioClient.instance.post(
        '/api/map/$mapId/invite',
        data: {'friendId': friendId},
        options: DioClient.authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // 지도 초대 수락
  Future<void> acceptMapInvitation(String accessToken, int mapMemberId) async {
    try {
      await DioClient.instance.post(
        '/api/map/member/$mapMemberId/accept',
        options: DioClient.authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // 지도 초대 거절
  Future<void> rejectMapInvitation(String accessToken, int mapMemberId) async {
    try {
      await DioClient.instance.post(
        '/api/map/member/$mapMemberId/reject',
        options: DioClient.authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // 지도 수정 (multipart/form-data)
  Future<void> updateMap(
    String accessToken,
    int mapId,
    String mapName,
    String? description, [
    File? backgroundImage,
  ]) async {
    try {
      final requestJson = jsonEncode({
        'mapName': mapName,
        if (description != null) 'description': description,
      });
      final formData = FormData.fromMap({
        'request': MultipartFile.fromString(
          requestJson,
          contentType: DioMediaType('application', 'json'),
        ),
        if (backgroundImage != null)
          'backgroundImage': await MultipartFile.fromFile(backgroundImage.path),
      });
      await DioClient.instance.put(
        '/api/map/$mapId',
        data: formData,
        options: DioClient.authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // 지도 삭제
  Future<void> deleteMap(String accessToken, int mapId) async {
    try {
      await DioClient.instance.delete(
        '/api/map/$mapId',
        options: DioClient.authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }
}
