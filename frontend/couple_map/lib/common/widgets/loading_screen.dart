import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
