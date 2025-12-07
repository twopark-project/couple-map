import 'dart:convert';

class CreateMemoryRequest {
  final String title;
  final String? content;
  final String placeName;
  final DateTime memoryDate;
  final double latitude;
  final double longitude;

  CreateMemoryRequest({
    required this.title,
    this.content,
    required this.placeName,
    required this.memoryDate,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'placeName': placeName,
      'memoryDate': memoryDate.toIso8601String().split('T')[0], // YYYY-MM-DD 형식
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
