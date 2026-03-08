class UserModel {
  final int userId;
  final String email;
  final String name;
  final String nickname;
  final String? profileImageUrl;
  final String friendCode;
  final String? createdAt; 

  const UserModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.nickname,
    this.profileImageUrl,
    required this.friendCode,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      friendCode: json['friendCode'] as String,
      createdAt: json['createdAt'] as String?,
    );
  }

  int get dDays {
    if (createdAt == null) return 0;
    final dt = DateTime.tryParse(createdAt!);
    if (dt == null) return 0;
    return DateTime.now().difference(dt).inDays;
  }
}
