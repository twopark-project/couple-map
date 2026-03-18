import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'app.dart';

import 'features/memory/presentation/screens/memory_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '',
    javaScriptAppKey: dotenv.env['KAKAO_JAVASCRIPT_APP_KEY'] ?? '',
  );

  AuthRepository.initialize(
    appKey: dotenv.env['KAKAO_JAVASCRIPT_APP_KEY'] ?? '',
  );

  // runApp(
  //   const ProviderScope(
  //     child: CoupleMapApp(),
  //   ),
  // );

  runApp(
    ProviderScope(
      // <-- 2. 여기에 'const'가 있다면 지우세요!
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MemoryDetailScreen(
          mapId: 3,
          memoryId: 1,
        ), // <-- 3. 여기서 에러가 나면 Ctrl + . 눌러서 자동 import
      ),
    ),
  );
}
