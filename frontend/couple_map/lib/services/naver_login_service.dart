import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_token.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'api_service.dart';
import '../models/auth/login_token_response.dart';

class NaverLoginService {
  final ApiService _apiService = ApiService();

  // 네이버 로그인
  Future<LoginTokenResponse> login() async {
    try {
      // 네이버 로그인 수행
      final NaverLoginResult result = await FlutterNaverLogin.logIn();

      if (result.status != NaverLoginStatus.loggedIn) {
        throw '네이버 로그인이 취소되었습니다.';
      }

      // 네이버 액세스 토큰 가져오기
      final NaverToken naverToken =
          await FlutterNaverLogin.getCurrentAccessToken();

      if (!naverToken.isValid()) {
        throw '네이버 액세스 토큰이 유효하지 않습니다.';
      }

      // 네이버에서 받은 액세스 토큰을 백엔드로 전송
      return await _apiService.loginWithNaver(naverToken.accessToken);
    } catch (e) {
      throw '네이버 로그인 실패: ${e.toString()}';
    }
  }
}
