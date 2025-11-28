class FriendPendingInfo {
  final int friendshipId;
  final String nickname;
  final String email;
  final String? imageUrl;

  FriendPendingInfo({
    required this.friendshipId,
    required this.nickname,
    required this.email,
    this.imageUrl,
  });

  factory FriendPendingInfo.fromJson(Map<String, dynamic> json) {
    return FriendPendingInfo(
      friendshipId: json['friendshipId'] as int,
      nickname: json['nickname'] as String,
      email: json['email'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
