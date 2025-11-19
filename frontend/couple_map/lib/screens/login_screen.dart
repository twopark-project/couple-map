import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/kakao_login_service.dart';
import '../services/google_login_service.dart';
import '../services/naver_login_service.dart';
import '../models/token_response.dart';

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
      final TokenResponse token = await _kakaoLoginService.login();
      await _saveToken(token);
      if (!context.mounted) return;
      _showSuccessDialog('카카오 로그인 성공!');
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
      final TokenResponse token = await _googleLoginService.login();
      if (!context.mounted) return;
      _showSuccessDialog('구글 로그인 성공!');
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
      final TokenResponse token = await _naverLoginService.login();
      await _saveToken(token);
      if (!context.mounted) return;
      _showSuccessDialog('네이버 로그인 성공!');
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
  Future<void> _saveToken(TokenResponse token) async {
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

  // 성공 다이얼로그
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('성공'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 에러 다이얼로그
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 앱 로고 또는 타이틀
                const Text(
                  'Couple Map',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '소셜 로그인으로 시작하기',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 60),

                // 로딩 인디케이터
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      // 카카오 로그인 버튼
                      _buildLoginButton(
                        onPressed: _handleKakaoLogin,
                        backgroundColor: const Color(0xFFFFE812),
                        textColor: Colors.black87,
                        icon: Icons.chat_bubble,
                        label: '카카오로 시작하기',
                      ),
                      const SizedBox(height: 16),

                      // 구글 로그인 버튼
                      _buildLoginButton(
                        onPressed: _handleGoogleLogin,
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        icon: Icons.g_mobiledata,
                        label: 'Google로 시작하기',
                        hasBorder: true,
                      ),
                      const SizedBox(height: 16),

                      // 네이버 로그인 버튼
                      _buildLoginButton(
                        onPressed: _handleNaverLogin,
                        backgroundColor: const Color(0xFF03C75A),
                        textColor: Colors.white,
                        icon: Icons.login,
                        label: '네이버로 시작하기',
                      ),
                    ],
                  ),
              ],
            ),
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
    required IconData icon,
    required String label,
    bool hasBorder = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor, size: 28),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: hasBorder
                ? const BorderSide(color: Colors.grey, width: 1)
                : BorderSide.none,
          ),
          elevation: hasBorder ? 0 : 2,
        ),
      ),
    );
  }
}
