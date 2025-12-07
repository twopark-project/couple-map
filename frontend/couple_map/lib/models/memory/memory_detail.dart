import 'media_file.dart';

class MemoryDetail {
  final int memoryId;
  final String title;
  final String? content;
  final String placeName;
  final DateTime memoryDate;
  final double latitude;
  final double longitude;
  final List<MediaFile> mediaFiles;

  MemoryDetail({
    required this.memoryId,
    required this.title,
    this.content,
    required this.placeName,
    required this.memoryDate,
    required this.latitude,
    required this.longitude,
    required this.mediaFiles,
  });

  factory MemoryDetail.fromJson(Map<String, dynamic> json) {
    return MemoryDetail(
      memoryId: json['memoryId'] as int,
      title: json['title'] as String,
      content: json['content'] as String?,
      placeName: json['placeName'] as String,
      memoryDate: DateTime.parse(json['memoryDate'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      mediaFiles: (json['mediaFiles'] as List?)
              ?.map((file) => MediaFile.fromJson(file))
              .toList() ??
          [],
    );
  }
}
