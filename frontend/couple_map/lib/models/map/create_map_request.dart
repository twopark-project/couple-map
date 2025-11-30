class CreateMapRequest {
  final String mapName;
  final String? description;

  CreateMapRequest({
    required this.mapName,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'mapName': mapName,
      'description': description,
    };
  }
}
