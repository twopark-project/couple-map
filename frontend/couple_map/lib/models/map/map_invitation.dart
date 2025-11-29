class MapInvitation {
  final int mapMemberId;
  final String mapName;
  final String inviterName;

  MapInvitation({
    required this.mapMemberId,
    required this.mapName,
    required this.inviterName,
  });

  factory MapInvitation.fromJson(Map<String, dynamic> json) {
    return MapInvitation(
      mapMemberId: json['mapMemberId'] as int,
      mapName: json['mapName'] as String,
      inviterName: json['inviterName'] as String,
    );
  }
}
