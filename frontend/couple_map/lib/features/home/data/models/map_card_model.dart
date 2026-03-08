// 기존 lib/models/map/map_list.dart에서 이식

class MapCardModel {
  final int mapId;
  final String mapName;
  final String? description;
  final String myRole; // OWNER, EDITOR, VIEWER, PENDING
  final String? thumbnailUrl;

  const MapCardModel({
    required this.mapId,
    required this.mapName,
    this.description,
    required this.myRole,
    this.thumbnailUrl,
  });

  factory MapCardModel.fromJson(Map<String, dynamic> json) {
    return MapCardModel(
      mapId: json['mapId'] as int,
      mapName: json['mapName'] as String,
      description: json['description'] as String?,
      myRole: json['myRole'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }
}
