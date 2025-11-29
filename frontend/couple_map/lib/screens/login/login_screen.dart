import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/kakao_login_service.dart';
import '../../services/google_login_service.dart';
import '../../services/naver_login_service.dart';
import '../../models/auth/login_token_response.dart';
import '../nickname/nickname_screen.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final KakaoLoginService _kakaoLoginService = KakaoLoginService();
  final GoogleLoginService _googleLoginService = GoogleLoginService();
  final NaverLoginService _naverLoginService = NaverLoginService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = false;

  // 카카오 로그인 처리
  Future<void> _handleKakaoLogin() async {
    setState(() => _isLoading = true);

    try {
      final LoginTokenResponse token = await _kakaoLoginService.login();
      await _saveToken(token);
      if (!context.mounted) return;
      _navigateAfterLogin(token);
    } catch (e) {
       if (!context.mounted) return;
      _showErrorDialog(e.toString());
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 구글 로그인 처리
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final LoginTokenResponse token = await _googleLoginService.login();
      await _saveToken(token);
      if (!context.mounted) return;
      _navigateAfterLogin(token);
    } catch (e) {
      if (!context.mounted) return;
      _showErrorDialog(e.toString());
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 네이버 로그인 처리
  Future<void> _handleNaverLogin() async {
    setState(() => _isLoading = true);

    try {
      final LoginTokenResponse token = await _naverLoginService.login();
      await _saveToken(token);
      if (!context.mounted) return;
      _navigateAfterLogin(token);
    } catch (e) {
      if (!context.mounted) return;
      _showErrorDialog(e.toString());
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 토큰 저장
  Future<void> _saveToken(LoginTokenResponse token) async {
    await _secureStorage.write(key: 'accessToken', value: token.accessToken);
    if (token.refreshToken != null) {
      await _secureStorage.write(
          key: 'refreshToken', value: token.refreshToken);
    }
    if (token.expiresIn != null) {
      await _secureStorage.write(
          key: 'expiresIn', value: token.expiresIn.toString());
    }
  }

  // 로그인 후 화면 이동 처리
  void _navigateAfterLogin(LoginTokenResponse token) {
    if (token.nicknameSet) {
      // 닉네임이 설정되어 있으면 대시보드로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    } else {
      // 닉네임이 설정되어 있지 않으면 닉네임 설정 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => NicknameScreen(
            accessToken: token.accessToken,
          ),
        ),
      );
    }
  }

  // 에러 다이얼로그
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '오류',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF3182F6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              '확인',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // 앱 로고 또는 타이틀
              const Text(
                'Couple Map',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4E5968),
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '우리만의 특별한 순간을\n지도에 기록해보세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),

              // 로딩 인디케이터 또는 버튼들
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3182F6)),
                  ),
                )
              else
                Column(
                  children: [
                    // 카카오 로그인 버튼
                    _buildLoginButton(
                      onPressed: _handleKakaoLogin,
                      backgroundColor: const Color(0xFFFEE500),
                      textColor: const Color(0xFF191919),
                      label: '카카오로 시작하기',
                    ),
                    const SizedBox(height: 12),

                    // 구글 로그인 버튼
                    _buildLoginButton(
                      onPressed: _handleGoogleLogin,
                      backgroundColor: Colors.white,
                      textColor: const Color(0xFF4E5968),
                      label: 'Google로 시작하기',
                      hasBorder: true,
                    ),
                    const SizedBox(height: 12),

                    // 네이버 로그인 버튼
                    _buildLoginButton(
                      onPressed: _handleNaverLogin,
                      backgroundColor: const Color(0xFF03C75A),
                      textColor: Colors.white,
                      label: '네이버로 시작하기',
                    ),
                  ],
                ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  // 로그인 버튼 위젯
  Widget _buildLoginButton({
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    required String label,
    bool hasBorder = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: hasBorder
                ? BorderSide(color: Colors.grey[300]!, width: 1.5)
                : BorderSide.none,
          ),
          elevation: hasBorder ? 0 : 0.5,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}
