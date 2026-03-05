import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'primary_button.dart';

class PermissionScreen extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onAllow;

  const PermissionScreen({
    super.key,
    required this.title,
    required this.description,
    required this.onAllow,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔐', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 24),
              Text(title,
                  style: AppTextStyles.heading1, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(description,
                  style: AppTextStyles.caption.copyWith(height: 1.6),
                  textAlign: TextAlign.center),
              const SizedBox(height: 40),
              PrimaryButton(label: '허용하기', onTap: onAllow),
            ],
          ),
        ),
      ),
    );
  }
}
