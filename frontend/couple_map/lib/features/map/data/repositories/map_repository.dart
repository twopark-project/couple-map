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
}
