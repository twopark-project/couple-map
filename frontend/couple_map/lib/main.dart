import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'app.dart';
import 'config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.validate();

  KakaoSdk.init(
    nativeAppKey: AppConfig.kakaoNativeAppKey,
    javaScriptAppKey: AppConfig.kakaoJavaScriptAppKey,
  );

  AuthRepository.initialize(
    appKey: AppConfig.kakaoJavaScriptAppKey,
  );

  runApp(
    const ProviderScope(
      child: CoupleMapApp(),
    ),
  );
}
