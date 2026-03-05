import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// TODO: 빈 상태 위젯 구현 예정
class EmptyHomeWidget extends StatelessWidget {
  final VoidCallback onCreateMap;

  const EmptyHomeWidget({super.key, required this.onCreateMap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🗺️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('아직 지도가 없어요', style: AppTextStyles.heading1),
          const SizedBox(height: 8),
          Text('첫 번째 지도를 만들어보세요', style: AppTextStyles.caption),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onCreateMap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('지도 만들기',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
