import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'api_service.dart';
import '../models/auth/login_token_response.dart';

class KakaoLoginService {
  final ApiService _apiService = ApiService();

  // 카카오 로그인
  Future<LoginTokenResponse> login() async {
    try {
      // 카카오톡 설치 여부 확인
      bool installed = await isKakaoTalkInstalled();

      OAuthToken token;
      if (installed) {
        // 카카오톡으로 로그인
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        // 카카오 계정으로 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      // 카카오에서 받은 액세스 토큰을 백엔드로 전송
      return await _apiService.loginWithKakao(token.accessToken);
    } catch (e) {
      throw '카카오 로그인 실패: ${e.toString()}';
    }
  }
}
