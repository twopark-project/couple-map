import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/models/map_card_model.dart';

class MapCardWidget extends StatelessWidget {
  final MapCardModel map;
  final VoidCallback? onTap;

  const MapCardWidget({super.key, required this.map, this.onTap});

  static const _gradients = [
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFFF093FB), Color(0xFFF5576C)],
    [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    [Color(0xFF43E97B), Color(0xFF38F9D7)],
    [Color(0xFFFFA751), Color(0xFFFFE259)],
    [Color(0xFFFC466B), Color(0xFF3F5EFB)],
  ];

  List<Color> get _gradient =>
      _gradients[map.mapId.abs() % _gradients.length];

  static const _categoryEnglish = {
    '나 혼자': 'Solo',
    '친구들과': 'Friends',
    '연인과': 'Couple',
    '가족': 'Family',
    'Solo': 'Solo',
    'Friends': 'Friends',
    'Couple': 'Couple',
    'Family': 'Family',
  };

  String get _categoryLabel =>
      _categoryEnglish[map.category] ?? map.category ?? '';

  String get _formattedDate {
    if (map.createdAt == null) return '';
    try {
      final dt = DateTime.parse(map.createdAt!);
      return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (map.backgroundUrl != null)
                CachedNetworkImage(
                  imageUrl: map.backgroundUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _buildGradientBg(),
                )
              else
                _buildGradientBg(),
              // 다크 오버레이
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x66000000),
                      Color(0x00000000),
                      Color(0x80000000),
                    ],
                    stops: [0, 0.4, 1],
                  ),
                ),
              ),
              // 텍스트 레이어
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 상단: 제목 + 카테고리 | 날짜
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          map.mapName,
                          style: const TextStyle(
                            fontFamily: 'Gaegu',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Color(0x4D000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _categoryLabel.isNotEmpty && _formattedDate.isNotEmpty
                              ? '$_categoryLabel | $_formattedDate'
                              : _categoryLabel.isNotEmpty
                                  ? _categoryLabel
                                  : _formattedDate,
                          style: const TextStyle(
                            fontFamily: 'NotoSansKR',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                            shadows: [
                              Shadow(
                                color: Color(0x4D000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // 하단 우측: 설명
                    if (map.description != null &&
                        map.description!.isNotEmpty)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          map.description!,
                          style: const TextStyle(
                            fontFamily: 'NotoSansKR',
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Color(0x4D000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientBg() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradient,
        ),
      ),
    );
  }
}
