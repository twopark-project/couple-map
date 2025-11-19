import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';
import '../models/token_response.dart';

class GoogleLoginService {
  final ApiService _apiService = ApiService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // 구글 로그인
  Future<TokenResponse> login() async {
    try {
      // 구글 로그인 수행
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw '구글 로그인이 취소되었습니다.';
      }

      // 구글 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null) {
        throw '구글 액세스 토큰을 가져올 수 없습니다.';
      }

      // 구글에서 받은 액세스 토큰을 백엔드로 전송
      return await _apiService.loginWithGoogle(googleAuth.accessToken!);
    } catch (e) {
      throw '구글 로그인 실패: ${e.toString()}';
    }
  }
}
