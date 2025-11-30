class NicknameRequest {
  final String nickname;

  NicknameRequest({required this.nickname});

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
    };
  }
}
