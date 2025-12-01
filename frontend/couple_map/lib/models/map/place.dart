class Place {
  final String placeName;
  final String addressName;
  final String categoryName;
  final String x; // 경도 (longitude)
  final String y; // 위도 (latitude)

  Place({
    required this.placeName,
    required this.addressName,
    required this.categoryName,
    required this.x,
    required this.y,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeName: json['place_name'] ?? '',
      addressName: json['address_name'] ?? '',
      categoryName: json['category_name'] ?? '',
      x: json['x'] ?? '',
      y: json['y'] ?? '',
    );
  }
}