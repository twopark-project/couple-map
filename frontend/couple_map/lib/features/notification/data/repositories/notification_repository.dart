import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class NotificationRepository {
  Future<List<dynamic>> getNotifications(String accessToken) async {
    try {
      final response = await DioClient.instance.get(
        '/api/notifications',
        options: DioClient.authOptions(accessToken),
      );
      return response.data['data'] as List? ?? [];
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }
}
