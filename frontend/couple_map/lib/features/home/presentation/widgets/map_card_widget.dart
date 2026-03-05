import 'package:flutter/material.dart';
import '../../data/models/map_card_model.dart';

// TODO: 지도 카드 위젯 구현 예정
class MapCardWidget extends StatelessWidget {
  final MapCardModel map;
  final VoidCallback? onTap;

  const MapCardWidget({super.key, required this.map, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(child: Text(map.mapName)),
    );
  }
}
