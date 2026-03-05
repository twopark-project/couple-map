import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class CalendarRepository {
  // TODO: 캘린더 관련 API 연동 예정
  Future<List<dynamic>> getCalendarEvents(String accessToken, int mapId, int year, int month) async {
    try {
      final response = await DioClient.instance.get(
        '/api/maps/$mapId/memories/calendar',
        queryParameters: {'year': year, 'month': month},
        options: DioClient.authOptions(accessToken),
      );
      return response.data['data'] as List? ?? [];
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }
}
