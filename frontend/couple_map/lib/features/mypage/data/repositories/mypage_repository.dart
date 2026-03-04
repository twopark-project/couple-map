import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user_model.dart';

class MypageRepository {
  Future<UserModel> getUserInfo(String accessToken) async {
    try {
      final response = await DioClient.instance.get(
        '/api/users/me',
        options: DioClient.authOptions(accessToken),
      );
      return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<void> updateNickname(String accessToken, String nickname) async {
    try {
      await DioClient.instance.patch(
        '/api/users/nickname',
        data: {'nickname': nickname},
        options: DioClient.authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }
}
