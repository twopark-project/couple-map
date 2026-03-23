import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user_model.dart';
import 'dart:io';

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

  Future<String> updateNickname(String accessToken, String nickname) async {
    try {
      final response = await DioClient.instance.post(
        '/api/users/nickname',
        data: {'nickname': nickname},
        options: DioClient.authOptions(accessToken),
      );
      return response.data['data']['nickname'] as String;
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<String> uploadProfileImage(String accessToken, File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
      });
      final response = await DioClient.instance.post(
        '/api/users/profile-image',
        data: formData,
        options: DioClient.authOptions(accessToken),
      );
      return response.data['data']['imageUrl'] as String;
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<void> deleteProfileImage(String accessToken) async {
    try {
      await DioClient.instance.delete(
        '/api/users/profile-image',
        options: DioClient.authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<void> deleteAccount(String accessToken) async {
    try {
      await DioClient.instance.delete(
        '/api/users/me',
        options: DioClient.authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }
}
