class TokenResponse {
  final String accessToken;
  final String? refreshToken;
  final int? expiresIn;

  TokenResponse({
    required this.accessToken,
    this.refreshToken,
    this.expiresIn,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'];
    if (accessToken  == null || accessToken is! String) {
      throw FormatException('accessToken이 필수값이거나 잘못된 형식입니다.');
    }
    return TokenResponse(
      accessToken: accessToken,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: json['expiresIn'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
    };
  }
}
