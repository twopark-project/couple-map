import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/map_card_model.dart';

class HomeRepository {
  // 지도 목록 조회
  Future<List<MapCardModel>> getMapList(String accessToken) async {
    try {
      final response = await DioClient.instance.get(
        '/api/map',
        options: DioClient.authOptions(accessToken),
      );
      final data = response.data['data'] as List;
      return data.map((json) => MapCardModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // 지도 생성
  Future<int> createMap(String accessToken, String mapName, String? description) async {
    try {
      final response = await DioClient.instance.post(
        '/api/map',
        data: {'mapName': mapName, 'description': description},
        options: DioClient.authOptions(accessToken),
      );
      return response.data['data'] as int;
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }
}
