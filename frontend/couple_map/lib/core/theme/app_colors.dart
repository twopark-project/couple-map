import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background
  static const Color background = Color(0xFFFDFBF7);
  static const Color cardBackground = Colors.white;

  // Primary (red-pink gradient)
  static const Color primary = Color(0xFFFF7A7A);
  static const Color primaryLight = Color(0xFFFF8E8E);

  // Text
  static const Color textDark = Color(0xFF2C2C2C);
  static const Color textGray = Color(0xFF888888);
  static const Color textLight = Color(0xFFAAAAAA);
  static const Color textDisabled = Color(0xFF999999);

  // Border
  static const Color border = Color(0xFFECE8E4);
  static const Color borderLight = Color(0xFFF0ECE8);
  static const Color borderDisabled = Color(0xFFE0E0E0);

  // Divider
  static const Color divider = Color(0xFFF5F5F5);

  // Social login
  static const Color kakao = Color(0xFFFEE500);
  static const Color kakaoText = Color(0xFF191919);
  static const Color naver = Color(0xFF03C75A);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
