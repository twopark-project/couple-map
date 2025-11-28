class NicknameResponse {
  final String nickname;

  NicknameResponse({required this.nickname});

  factory NicknameResponse.fromJson(Map<String, dynamic> json) {
    return NicknameResponse(
      nickname: json['nickname'] as String,
    );
  }
}
