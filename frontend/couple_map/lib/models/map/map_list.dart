class MapList {
  final int mapId;
  final String mapName;
  final String? description;
  final String myRole; // OWNER, EDITOR, VIEWER, PENDING

  MapList({
    required this.mapId,
    required this.mapName,
    this.description,
    required this.myRole,
  });

  factory MapList.fromJson(Map<String, dynamic> json) {
    return MapList(
      mapId: json['mapId'] as int,
      mapName: json['mapName'] as String,
      description: json['description'] as String?,
      myRole: json['myRole'] as String,
    );
  }
}
