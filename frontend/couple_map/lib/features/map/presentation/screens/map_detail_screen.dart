import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../memory/data/models/memory_model.dart';
import '../../../memory/data/repositories/memory_repository.dart';
import '../../../memory/presentation/screens/memory_detail_screen.dart';
import '../../../memory/presentation/screens/memory_create_screen.dart';
import 'place_search_screen.dart';

class MapDetailScreen extends ConsumerStatefulWidget {
  final int mapId;
  final String? mapName;

  const MapDetailScreen({super.key, required this.mapId, this.mapName});

  @override
  ConsumerState<MapDetailScreen> createState() => _MapDetailScreenState();
}

class _MapDetailScreenState extends ConsumerState<MapDetailScreen> {
  KakaoMapController? mapController;
  final MemoryRepository _memoryRepo = MemoryRepository();

  List<MemorySummary> _memories = [];

  // 초기 지도 중심 좌표 (서울 시청)
  final LatLng _initialPosition = LatLng(37.5665, 126.9780);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMemories();
    });
  }

  // 추억 목록 로드
  Future<void> _loadMemories() async {
    if (!mounted) return;
    try {
      final auth = ref.read(authProvider);
      if (auth is! AuthSuccess) return;
      final memories =
          await _memoryRepo.getMemoryList(auth.token.accessToken, widget.mapId);
      if (!mounted) return;
      setState(() => _memories = memories);
    } catch (e) {
      debugPrint('추억 목록 로드 실패: $e');
    }
  }

  // 장소 검색 화면으로 이동
  Future<void> _openPlaceSearch() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const PlaceSearchScreen()),
    );
    if (result == null || !mounted) return;

    final lat = result['latitude'] as double;
    final lng = result['longitude'] as double;

    // 지도 이동
    mapController?.setCenter(LatLng(lat, lng));
    mapController?.setLevel(3);

    // 추억 생성 화면으로 이동
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MemoryCreateScreen(
          mapId: widget.mapId,
          placeName: result['name'] as String?,
          placeAddress: result['address'] as String?,
          latitude: lat,
          longitude: lng,
        ),
      ),
    );

    if (saved == true) {
      await _loadMemories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '추억이 저장되었습니다',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF3182F6),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  // 마커 클릭 이벤트
  void _onMarkerTap(String markerId, LatLng latLng, int zoomLevel) {
    mapController?.setCenter(latLng);
    mapController?.setLevel(3);

    final memory = _memories.firstWhere(
      (m) => m.memoryId.toString() == markerId,
      orElse: () => _memories.first,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemoryDetailScreen(
          mapId: widget.mapId,
          memoryId: memory.memoryId,
        ),
      ),
    );
  }

  // 클러스터 클릭 이벤트
  void _onClustererTap(
      LatLng latLng, int zoomLevel, List<Marker> clusterMarkers) {
    mapController?.setCenter(latLng);
    mapController?.setLevel((zoomLevel - 2).clamp(1, 14));
  }

  // 클러스터러 생성
  Clusterer? _createClusterer() {
    if (_memories.isEmpty) return null;
    final markers = _memories
        .map((memory) => Marker(
              markerId: memory.memoryId.toString(),
              latLng: LatLng(memory.latitude, memory.longitude),
              width: 30,
              height: 35,
            ))
        .toList();

    return Clusterer(
      markers: markers,
      minLevel: 1,
      disableClickZoom: false,
      styles: [
        ClustererStyle(
          width: 40,
          height: 40,
          background: const Color(0xFFFF8E8E),
          color: Colors.white,
          borderRadius: 20,
          textAlign: 'center',
          lineHeight: 40,
        ),
      ],
    );
  }

  // 추억 목록 Bottom Sheet
  void _showMemoryListBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // 핸들바
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 헤더
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Text(
                    '추억 목록',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8E8E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_memories.length}',
                      style: const TextStyle(
                        color: Color(0xFFFF8E8E),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 목록
            Expanded(
              child: _memories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library_outlined,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            '저장된 추억이 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '장소를 검색하여 추억을 만들어보세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _memories.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final memory = _memories[index];
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            mapController?.setCenter(
                                LatLng(memory.latitude, memory.longitude));
                            mapController?.setLevel(3);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MemoryDetailScreen(
                                  mapId: widget.mapId,
                                  memoryId: memory.memoryId,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: Colors.grey[200]!, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // 썸네일
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: memory.thumbnailUrl != null
                                      ? Image.network(
                                          memory.thumbnailUrl!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _placeholderThumbnail(),
                                        )
                                      : _placeholderThumbnail(),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        memory.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF191919),
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.place,
                                              size: 13, color: Colors.grey),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              memory.placeName,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (memory.memoryDate != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '${memory.memoryDate!.year}.${memory.memoryDate!.month.toString().padLeft(2, '0')}.${memory.memoryDate!.day.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios,
                                    size: 14, color: Colors.grey),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderThumbnail() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFF8E8E).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image, color: Color(0xFFFF8E8E), size: 26),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        surfaceTintColor: const Color(0xFFFDFBF7),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF0ECE8)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C2C2C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.mapName ?? '',
          style: const TextStyle(
            color: Color(0xFF2C2C2C),
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 지도 설정 화면으로 이동
            },
            child: const Text(
              '설정',
              style: TextStyle(
                color: Color(0xFFFF8E8E),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 카카오맵
          Positioned.fill(
            child: KakaoMap(
              onMapCreated: (controller) {
                mapController = controller;
                controller.setLevel(5);
              },
              center: _initialPosition,
              clusterer: _createClusterer(),
              onMarkerTap: _onMarkerTap,
              onMarkerClustererTap: _onClustererTap,
            ),
          ),

          // 검색창 (탭하면 장소 검색 화면으로 이동)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _openPlaceSearch,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      shadowColor: Colors.black.withValues(alpha: 0.08),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            const Text('🔍', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              '장소, 주소 검색',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 필터 버튼
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.filter_list_rounded,
                        color: Color(0xFF2C2C2C),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'memory_list',
        onPressed: _showMemoryListBottomSheet,
        backgroundColor: Colors.white,
        elevation: 4,
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.list_alt,
                color: Color(0xFFFF8E8E),
                size: 26,
              ),
            ),
            if (_memories.isNotEmpty)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF8E8E),
                    shape: BoxShape.circle,
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${_memories.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
