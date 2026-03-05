import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'primary_button.dart';

enum ErrorType { network, server }

class ErrorScreen extends StatelessWidget {
  final ErrorType type;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    this.type = ErrorType.network,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork = type == ErrorType.network;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isNetwork ? '🌐' : '⚠️',
                  style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 24),
              Text(
                isNetwork ? '인터넷 연결을 확인해주세요' : '서버 오류가 발생했어요',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isNetwork
                    ? 'Wi-Fi 또는 데이터 연결 상태를 확인한 후\n다시 시도해주세요.'
                    : '일시적인 오류입니다. 잠시 후 다시 시도해주세요.',
                style: AppTextStyles.caption.copyWith(height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (onRetry != null)
                PrimaryButton(label: '다시 시도', onTap: onRetry),
            ],
          ),
        ),
      ),
    );
  }
}
