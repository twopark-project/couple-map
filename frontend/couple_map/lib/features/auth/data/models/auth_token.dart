class AuthToken {
  final String accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final bool nicknameSet;

  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    this.expiresIn,
    required this.nicknameSet,
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'];
    if (accessToken == null || accessToken is! String) {
      throw const FormatException('accessToken이 필수값이거나 잘못된 형식입니다.');
    }

    int? expiresIn;
    if (json['expiresIn'] != null) {
      if (json['expiresIn'] is int) {
        expiresIn = json['expiresIn'] as int;
      } else if (json['expiresIn'] is String) {
        expiresIn = int.tryParse(json['expiresIn']);
      }
    }

    return AuthToken(
      accessToken: accessToken,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: expiresIn,
      nicknameSet: json['isNicknameSet'] as bool? ?? false,
    );
  }
}
