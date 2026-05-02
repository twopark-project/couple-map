class AppConfig {
  AppConfig._();

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );
  static const String baseUrl = String.fromEnvironment('BASE_URL');
  static const String kakaoNativeAppKey =
      String.fromEnvironment('KAKAO_NATIVE_APP_KEY');
  static const String kakaoJavaScriptAppKey =
      String.fromEnvironment('KAKAO_JAVASCRIPT_APP_KEY');
  static const String kakaoRestApiKey =
      String.fromEnvironment('KAKAO_REST_API_KEY');
  static const String naverClientId =
      String.fromEnvironment('NAVER_CLIENT_ID');
  static const String naverClientSecret =
      String.fromEnvironment('NAVER_CLIENT_SECRET');
  static const String naverClientName =
      String.fromEnvironment('NAVER_CLIENT_NAME');

  static bool get isProd => appEnv == 'prod';

  static void validate() {
    final missing = <String>[
      if (baseUrl.isEmpty) 'BASE_URL',
      if (kakaoNativeAppKey.isEmpty) 'KAKAO_NATIVE_APP_KEY',
      if (kakaoJavaScriptAppKey.isEmpty) 'KAKAO_JAVASCRIPT_APP_KEY',
      if (kakaoRestApiKey.isEmpty) 'KAKAO_REST_API_KEY',
      if (naverClientId.isEmpty) 'NAVER_CLIENT_ID',
      if (naverClientSecret.isEmpty) 'NAVER_CLIENT_SECRET',
      if (naverClientName.isEmpty) 'NAVER_CLIENT_NAME',
    ];

    if (missing.isNotEmpty) {
      throw StateError(
        'Missing required dart-define values: ${missing.join(', ')}',
      );
    }

    if (isProd && !baseUrl.startsWith('https://')) {
      throw StateError('Production BASE_URL must use https.');
    }
  }
}
