// 기존 lib/models/map/place.dart 에서 이식

class PlaceModel {
  final String placeName;
  final String addressName;
  final String categoryName;
  final String x; // 경도 (longitude)
  final String y; // 위도 (latitude)

  const PlaceModel({
    required this.placeName,
    required this.addressName,
    required this.categoryName,
    required this.x,
    required this.y,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      placeName: json['place_name'] ?? '',
      addressName: json['address_name'] ?? '',
      categoryName: json['category_name'] ?? '',
      x: json['x']?.toString() ?? '126.9780',
      y: json['y']?.toString() ?? '37.5665',
    );
  }
}
