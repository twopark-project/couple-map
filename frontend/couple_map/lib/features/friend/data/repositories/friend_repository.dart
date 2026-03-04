import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class FriendInfo {
  final int id;
  final String nickname;
  final String email;
  final String? imageUrl;

  const FriendInfo({
    required this.id,
    required this.nickname,
    required this.email,
    this.imageUrl,
  });

  factory FriendInfo.fromJson(Map<String, dynamic> json) {
    return FriendInfo(
      id: json['id'] as int,
      nickname: json['nickname'] as String,
      email: json['email'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class FriendPendingInfo {
  final int friendshipId;
  final String nickname;
  final String email;
  final String? imageUrl;

  const FriendPendingInfo({
    required this.friendshipId,
    required this.nickname,
    required this.email,
    this.imageUrl,
  });

  factory FriendPendingInfo.fromJson(Map<String, dynamic> json) {
    return FriendPendingInfo(
      friendshipId: json['friendshipId'] as int,
      nickname: json['nickname'] as String,
      email: json['email'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class FriendRepository {
  Future<List<FriendInfo>> getFriendList(String accessToken) async {
    try {
      final response = await DioClient.instance.get(
        '/api/friend/list',
        options: DioClient.authOptions(accessToken),
      );
      final data = response.data['data']['friendList'] as List;
      return data.map((j) => FriendInfo.fromJson(j as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<List<FriendPendingInfo>> getPendingFriendList(String accessToken) async {
    try {
      final response = await DioClient.instance.get(
        '/api/friend/list/pending',
        options: DioClient.authOptions(accessToken),
      );
      final data = response.data['data']['friendPendingInfoDtoList'] as List;
      return data.map((j) => FriendPendingInfo.fromJson(j as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<void> sendFriendRequest(String accessToken, String friendCode) async {
    try {
      await DioClient.instance.post(
        '/api/friend/request',
        data: {'friendCode': friendCode},
        options: DioClient.authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<void> acceptFriendRequest(String accessToken, int friendshipId) async {
    try {
      await DioClient.instance.post(
        '/api/friend/$friendshipId/accept',
        options: DioClient.authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }

  Future<void> rejectFriendRequest(String accessToken, int friendshipId) async {
    try {
      await DioClient.instance.post(
        '/api/friend/$friendshipId/reject',
        options: DioClient.authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }
}
