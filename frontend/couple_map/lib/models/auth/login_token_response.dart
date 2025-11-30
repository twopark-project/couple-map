class LoginTokenResponse {
  final String accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final bool nicknameSet;

  LoginTokenResponse({
    required this.accessToken,
    this.refreshToken,
    this.expiresIn,
    required this.nicknameSet,
  });

  factory LoginTokenResponse.fromJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'];
    if (accessToken == null || accessToken is! String) {
      throw FormatException('accessToken이 필수값이거나 잘못된 형식입니다.');
    }

    // expiresIn이 문자열로 올 수 있으므로 안전하게 변환
    int? expiresIn;
    if (json['expiresIn'] != null) {
      if (json['expiresIn'] is int) {
        expiresIn = json['expiresIn'] as int;
      } else if (json['expiresIn'] is String) {
        expiresIn = int.tryParse(json['expiresIn']);
      }
    }

    return LoginTokenResponse(
      accessToken: accessToken,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: expiresIn,
      nicknameSet: json['nicknameSet'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'nicknameSet': nicknameSet,
    };
  }
}
