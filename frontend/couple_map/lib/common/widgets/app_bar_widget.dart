import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppBarWidget extends StatelessWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;

  const AppBarWidget({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 15),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: onBack ?? () => context.pop(),
              child: const Icon(Icons.arrow_back_ios,
                  color: AppColors.textLight, size: 20),
            )
          else
            const SizedBox(width: 20),
          Expanded(
            child: Center(
              child: Text(title, style: AppTextStyles.heading2),
            ),
          ),
          SizedBox(width: 20, child: trailing),
        ],
      ),
    );
  }
}
