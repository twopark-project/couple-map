import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final BoxBorder? border;
  final String iconAsset;

  const SocialLoginButton._({
    super.key,
    required this.onTap,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.iconAsset,
    this.border,
  });

  factory SocialLoginButton.kakao({required VoidCallback onTap}) =>
      SocialLoginButton._(
        onTap: onTap,
        label: '카카오 로그인',
        backgroundColor: const Color(0xFFFEE500),
        textColor: const Color.fromRGBO(0, 0, 0, 0.85),
        iconAsset: 'assets/icons/kakao_symbol.png',
      );

  factory SocialLoginButton.naver({required VoidCallback onTap}) =>
      SocialLoginButton._(
        onTap: onTap,
        label: '네이버 로그인',
        backgroundColor: const Color(0xFF03A94D),
        textColor: Colors.white,
        iconAsset: 'assets/icons/naver_logo.png',
      );

  factory SocialLoginButton.google({required VoidCallback onTap}) =>
      SocialLoginButton._(
        onTap: onTap,
        label: '구글 로그인',
        backgroundColor: Colors.white,
        textColor: const Color(0xFF1F1F1F),
        border: Border.all(color: const Color(0xFF747775)),
        iconAsset: 'assets/icons/google_symbol.png',
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Image.asset(iconAsset, width: 20, height: 20),
            Expanded(
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 36),
          ],
        ),
      ),
    );
  }
}
