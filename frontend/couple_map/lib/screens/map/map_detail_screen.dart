import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import '../../models/map/map_list.dart';
import '../../models/map/place.dart';

class MapDetailScreen extends StatefulWidget {
  final MapList mapInfo;

  const MapDetailScreen({super.key, required this.mapInfo});

  @override
  State<MapDetailScreen> createState() => _MapDetailScreenState();
}

class _MapDetailScreenState extends State<MapDetailScreen> {
  late KakaoMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();

  List<Place> _searchResults = [];
  bool _isSearching = false;
  bool _showResults = false;

  Timer? _debounce; // 💡 Debouncing을 위한 Timer 추가

  // 초기 지도 중심 좌표 (서울 시청)
  final LatLng _initialPosition = LatLng(37.5665, 126.9780);

  @override
  void dispose() {
    _searchController.dispose();
    // 💡 위젯 종료 시 타이머가 활성화되어 있으면 취소
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    super.dispose();
  }

  // 💡 추가: Debouncing을 처리하는 함수
  void _handleSearch(String query) {
    // 이전 타이머가 활성화되어 있다면 취소
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // 0.5초 후에 _searchPlaces 함수를 호출하는 새로운 타이머 설정
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchPlaces(query);
    });
  }

  // 카카오 로컬 API로 장소 검색
  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showResults = true;
    });

    try {
      final restApiKey = dotenv.env['KAKAO_REST_API_KEY'] ?? '';
      final response = await _dio.get(
        'https://dapi.kakao.com/v2/local/search/keyword.json',
        queryParameters: {'query': query},
        options: Options(headers: {'Authorization': 'KakaoAK $restApiKey'}),
      );

      if (response.statusCode == 200) {
        final documents = response.data['documents'] as List;
        setState(() {
          _searchResults = documents.map((doc) => Place.fromJson(doc)).toList();
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('검색 실패: $e'),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    }
  }

  // 선택한 장소로 지도 이동
  void _moveToPlace(Place place) {
    final lat = double.parse(place.y);
    final lng = double.parse(place.x);

    // 로그 출력
    debugPrint('=== 선택한 장소 정보 ===');
    debugPrint('장소명: ${place.placeName}');
    debugPrint('주소: ${place.addressName}');
    debugPrint('위도(latitude): $lat');
    debugPrint('경도(longitude): $lng');
    debugPrint('=====================');

    // 지도 카메라 이동
    mapController.setCenter(LatLng(lat, lng));
    mapController.setLevel(3); // 줌 레벨 설정

    // 검색 결과 닫기
    setState(() {
      _showResults = false;
      _searchController.clear();
    });

    // 사용자에게 알림
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${place.placeName}로 이동했습니다'),
        backgroundColor: const Color(0xFF3182F6),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF191919)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.mapInfo.mapName,
              style: const TextStyle(
                color: Color(0xFF191919),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            if (widget.mapInfo.description != null)
              Text(
                widget.mapInfo.description!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 카카오맵 (전체 화면 크기 지정)
          Positioned.fill(
            child: KakaoMap(
              onMapCreated: (controller) {
                mapController = controller;
                // 초기 줌 레벨 설정
                mapController.setLevel(5);
              },
              center: _initialPosition,
            ),
          ),

          // 검색창
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: '장소 검색...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF3182F6),
                      size: 24,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[400]),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                                _showResults = false;
                              });
                              // 💡 클리어 시 타이머 취소
                              if (_debounce?.isActive ?? false) {
                                _debounce!.cancel();
                              }
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    // 💡 입력 변화 시 Debounce 처리 함수 호출 (0.5초 지연 검색)
                    _handleSearch(value);
                  },
                  onSubmitted: _searchPlaces, // 💡 엔터키 입력 시 즉시 검색 실행
                ),
              ),
            ),
          ),

          // 검색 결과 리스트
          if (_showResults)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              bottom: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _isSearching
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF3182F6),
                            ),
                          ),
                        )
                      : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '검색 결과가 없습니다',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final place = _searchResults[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF3182F6,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.place,
                                  color: Color(0xFF3182F6),
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                place.placeName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF191919),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (place.categoryName.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        place.categoryName,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      place.addressName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Color(0xFF3182F6),
                              ),
                              onTap: () => _moveToPlace(place),
                            );
                          },
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
