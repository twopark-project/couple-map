import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // 백엔드 서버 URL (.env 파일에서 읽음)
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

  // 소셜 로그인 엔드포인트
  static const String kakaoLoginUrl = '/api/login/social/kakao';
  static const String googleLoginUrl = '/api/login/social/google';
  static const String naverLoginUrl = '/api/login/social/naver';

  // 사용자 관련 엔드포인트
  static const String setNicknameUrl = '/api/users/nickname';
  static const String getUserInfoUrl = '/api/users/me';

  // 지도 관련 엔드포인트
  static const String getMapListUrl = '/api/map';
  static const String createMapUrl = '/api/map';
  static const String getMapInvitationsUrl = '/api/map/invitations';
  static String inviteFriendToMapUrl(int mapId) => '/api/map/$mapId/invite';
  static String acceptMapInvitationUrl(int mapMemberId) =>
      '/api/map/member/$mapMemberId/accept';
  static String rejectMapInvitationUrl(int mapMemberId) =>
      '/api/map/member/$mapMemberId/reject';

  // 친구 관련 엔드포인트
  static const String getFriendListUrl = '/api/friend/list';
  static const String getPendingFriendListUrl = '/api/friend/list/pending';
  static const String sendFriendRequestUrl = '/api/friend/request';
  static String acceptFriendRequestUrl(int friendshipId) =>
      '/api/friend/$friendshipId/accept';
  static String rejectFriendRequestUrl(int friendshipId) =>
      '/api/friend/$friendshipId/reject';

  // 인증 관련 엔드포인트
  static const String logoutUrl = '/api/auth/logout';
}
