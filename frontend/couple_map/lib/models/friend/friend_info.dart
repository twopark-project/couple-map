class FriendInfo {
  final int id;
  final String nickname;
  final String email;
  final String? imageUrl;

  FriendInfo({
    required this.id,
    required this.nickname,
    required this.email,
    this.imageUrl,
  });

  factory FriendInfo.fromJson(Map<String, dynamic> json) {
    return FriendInfo(
      id: json['id'] as int,
      nickname: json['nickname'] as String,
      email: json['email'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
