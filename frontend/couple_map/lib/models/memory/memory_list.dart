class MemoryList {
  final int memoryId;
  final String title;
  final String placeName;
  final double latitude;
  final double longitude;

  MemoryList({
    required this.memoryId,
    required this.title,
    required this.placeName,
    required this.latitude,
    required this.longitude,
  });

  factory MemoryList.fromJson(Map<String, dynamic> json) {
    return MemoryList(
      memoryId: json['memoryId'] as int,
      title: json['title'] as String,
      placeName: json['placeName'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
