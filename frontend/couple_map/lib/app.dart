import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/providers/auth_provider.dart';

class CoupleMapApp extends ConsumerWidget {
  const CoupleMapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    DioClient.onUnauthorized = () async {
      await const FlutterSecureStorage().deleteAll();
      ref.read(authProvider.notifier).reset();
      router.go('/login');
    };

    return MaterialApp.router(
      title: 'Couple Map',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
