// 기존 lib/models/map/ 에서 이식

class MapModel {
  final int mapId;
  final String mapName;
  final String? description;
  final String myRole; // OWNER, EDITOR, VIEWER, PENDING

  const MapModel({
    required this.mapId,
    required this.mapName,
    this.description,
    required this.myRole,
  });

  factory MapModel.fromJson(Map<String, dynamic> json) {
    return MapModel(
      mapId: json['mapId'] as int,
      mapName: json['mapName'] as String,
      description: json['description'] as String?,
      myRole: json['myRole'] as String,
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
