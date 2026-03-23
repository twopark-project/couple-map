// 기존 lib/models/map/ 에서 이식

class MapModel {
  final int mapId;
  final String mapName;
  final String? description;
  final String? backgroundUrl;
  final String myRole; // OWNER, EDITOR, VIEWER, PENDING
  final int memberCount;
  final String? category;

  const MapModel({
    required this.mapId,
    required this.mapName,
    this.description,
    this.backgroundUrl,
    required this.myRole,
    this.memberCount = 1,
    this.category,
  });

  factory MapModel.fromJson(Map<String, dynamic> json) {
    return MapModel(
      mapId: json['mapId'] as int,
      mapName: json['mapName'] as String,
      description: json['description'] as String?,
      backgroundUrl: json['backgroundUrl'] as String?,
      myRole: json['myRole'] as String,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 1,
      category: json['category'] as String?,
    );
  }
}

class MapMemberInfo {
  final int userId;
  final String nickname;
  final String? profileImageUrl;
  final String role;

  const MapMemberInfo({
    required this.userId,
    required this.nickname,
    this.profileImageUrl,
    required this.role,
  });

  factory MapMemberInfo.fromJson(Map<String, dynamic> json) {
    return MapMemberInfo(
      userId: json['userId'] as int,
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      role: json['role'] as String,
    );
  }
}

class MapInvitation {
  final int mapMemberId;
  final String mapName;
  final String inviterNickname;

  const MapInvitation({
    required this.mapMemberId,
    required this.mapName,
    required this.inviterNickname,
  });

  factory MapInvitation.fromJson(Map<String, dynamic> json) {
    return MapInvitation(
      mapMemberId: json['mapMemberId'] as int,
      mapName: json['mapName'] as String,
      inviterNickname: json['inviterNickname'] as String,
    );
  }
}
