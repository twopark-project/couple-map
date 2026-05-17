import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    height: 1.4,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: AppColors.textGray,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle hint = TextStyle(
    color: AppColors.textLight,
  );
}
