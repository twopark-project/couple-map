import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;
  final BoxBorder? border;

  const SocialLoginButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.border,
  });

  factory SocialLoginButton.kakao({required VoidCallback onTap}) =>
      SocialLoginButton(
        label: '카카오로 시작하기',
        backgroundColor: AppColors.kakao,
        textColor: AppColors.kakaoText,
        onTap: onTap,
      );

  factory SocialLoginButton.naver({required VoidCallback onTap}) =>
      SocialLoginButton(
        label: '네이버로 시작하기',
        backgroundColor: AppColors.naver,
        textColor: Colors.white,
        onTap: onTap,
      );

  factory SocialLoginButton.google({required VoidCallback onTap}) =>
      SocialLoginButton(
        label: 'Google로 계속하기',
        backgroundColor: Colors.white,
        textColor: const Color(0xFF333333),
        onTap: onTap,
        border: Border.all(color: AppColors.borderDisabled),
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
          borderRadius: BorderRadius.circular(16),
          border: border,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
