import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/place_model.dart';
import '../../../memory/data/models/memory_model.dart';
import '../../../memory/domain/providers/memory_provider.dart';

class MapDetailScreen extends ConsumerStatefulWidget {
  final int mapId;
  final String? mapName;
  final String? description;
  final int memberCount;

  const MapDetailScreen({
    super.key,
    required this.mapId,
    this.mapName,
    this.description,
    this.memberCount = 1,
  });

  @override
  ConsumerState<MapDetailScreen> createState() => _MapDetailScreenState();
}

class _MapDetailScreenState extends ConsumerState<MapDetailScreen> {
  KakaoMapController? mapController;
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();
  final ImagePicker _imagePicker = ImagePicker();

  List<PlaceModel> _searchResults = [];
  List<MemorySummary> _memories = [];
  bool _isSearching = false;
  bool _showResults = false;

  Timer? _debounce; // 💡 Debouncing을 위한 Timer 추가

  // 초기 지도 중심 좌표 (서울 시청)
  final LatLng _initialPosition = LatLng(37.5665, 126.9780);

  @override
  void initState() {
    super.initState();
    // 지도 로드 후 추억 목록 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMemories();
    });
  }

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
          _searchResults = documents.map((doc) => PlaceModel.fromJson(doc)).toList();
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

  // 선택한 장소로 지도 이동 및 추억 작성 모달 오픈
  void _moveToPlace(PlaceModel place) {
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
    mapController?.setCenter(LatLng(lat, lng));
    mapController?.setLevel(3); // 줌 레벨 설정

    // 검색 결과 닫기
    setState(() {
      _showResults = false;
      _searchController.clear();
    });

    // 추억 작성 모달 열기
    _showCreateMemoryModal(place);
  }

  // 추억 작성 모달
  Future<void> _showCreateMemoryModal(PlaceModel place) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    List<XFile> selectedImages = [];
    List<File> selectedVideos = [];
    List<File> selectedAudios = [];

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 헤더
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '추억 만들기',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.place, size: 16, color: Color(0xFF3182F6)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  place.placeName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3182F6),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // 콘텐츠
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 입력
                      const Text(
                        '제목',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191919),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: '추억의 제목을 입력하세요',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF3182F6), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 내용 입력
                      const Text(
                        '내용 (선택)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191919),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: contentController,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: '추억에 대한 설명을 입력하세요',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF3182F6), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 날짜 선택
                      const Text(
                        '날짜',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191919),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setModalState(() {
                              selectedDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Color(0xFF3182F6), size: 20),
                              const SizedBox(width: 12),
                              Text(
                                '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 사진 추가
                      const Text(
                        '사진 (선택)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191919),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // 사진 추가 버튼
                          InkWell(
                            onTap: () async {
                              final hasPermission = await _requestPhotoPermission();
                              if (!hasPermission) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('사진 접근 권한이 필요합니다'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                return;
                              }

                              final images = await _imagePicker.pickMultiImage();
                              if (images.isNotEmpty) {
                                setModalState(() {
                                  selectedImages.addAll(images);
                                });
                              }
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!, width: 1.5),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_photo_alternate, color: Color(0xFF3182F6), size: 28),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${selectedImages.length}/10',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 선택된 이미지 미리보기
                          if (selectedImages.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 80,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: selectedImages.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.file(
                                            File(selectedImages[index].path),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: InkWell(
                                            onTap: () {
                                              setModalState(() {
                                                selectedImages.removeAt(index);
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 비디오 추가
                      const Text(
                        '비디오 (선택)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191919),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final hasPermission = await _requestVideoPermission();
                          if (!hasPermission) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('비디오 접근 권한이 필요합니다'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }

                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.video,
                            allowMultiple: true,
                          );
                          if (result != null && result.files.isNotEmpty) {
                            setModalState(() {
                              selectedVideos.addAll(
                                result.files.map((file) => File(file.path!)).toList(),
                              );
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.videocam, color: Color(0xFF3182F6), size: 24),
                              const SizedBox(width: 12),
                              Text(
                                selectedVideos.isEmpty
                                    ? '비디오 선택'
                                    : '${selectedVideos.length}개 선택됨',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: selectedVideos.isEmpty ? Colors.grey[600] : const Color(0xFF3182F6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (selectedVideos.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...selectedVideos.asMap().entries.map((entry) {
                          final index = entry.key;
                          final video = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.play_circle_outline, color: Color(0xFF3182F6), size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    video.path.split('/').last,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () {
                                    setModalState(() {
                                      selectedVideos.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 20),

                      // 오디오 추가
                      const Text(
                        '오디오 (선택)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191919),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final hasPermission = await _requestAudioPermission();
                          if (!hasPermission) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('오디오 접근 권한이 필요합니다'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }

                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.audio,
                            allowMultiple: true,
                          );
                          if (result != null && result.files.isNotEmpty) {
                            setModalState(() {
                              selectedAudios.addAll(
                                result.files.map((file) => File(file.path!)).toList(),
                              );
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.audiotrack, color: Color(0xFF3182F6), size: 24),
                              const SizedBox(width: 12),
                              Text(
                                selectedAudios.isEmpty
                                    ? '오디오 선택'
                                    : '${selectedAudios.length}개 선택됨',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: selectedAudios.isEmpty ? Colors.grey[600] : const Color(0xFF3182F6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (selectedAudios.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...selectedAudios.asMap().entries.map((entry) {
                          final index = entry.key;
                          final audio = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.music_note, color: Color(0xFF3182F6), size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    audio.path.split('/').last,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () {
                                    setModalState(() {
                                      selectedAudios.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
              // 하단 버튼
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                '제목을 입력해주세요',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: Colors.red[400],
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3182F6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '추억 저장',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 사용자가 저장 버튼을 누른 경우
    if (result == true && mounted) {
      await _createMemory(
        place,
        titleController.text.trim(),
        contentController.text.trim().isEmpty ? null : contentController.text.trim(),
        selectedDate,
        selectedImages,
        selectedVideos,
        selectedAudios,
      );
    }

    titleController.dispose();
    contentController.dispose();
  }

  // 이미지 권한 확인 및 요청
  Future<bool> _requestPhotoPermission() async {
    try {
      var status = await Permission.photos.status;
      // 이미 권한이 있으면 바로 리턴
      if (status.isGranted || status.isLimited) {
        return true;
      }
      // 권한이 없으면 요청
      status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    } catch (e) {
      debugPrint('이미지 권한 요청 실패: $e');
      return false;
    }
  }

  // 비디오 권한 확인 및 요청
  Future<bool> _requestVideoPermission() async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.videos.status;
        // 이미 권한이 있으면 바로 리턴
        if (status.isGranted || status.isLimited) {
          return true;
        }
        // 권한이 없으면 요청
        status = await Permission.videos.request();
        return status.isGranted || status.isLimited;
      } else if (Platform.isIOS) {
        // iOS는 photos 권한으로 통합
        var status = await Permission.photos.status;
        if (status.isGranted || status.isLimited) {
          return true;
        }
        status = await Permission.photos.request();
        return status.isGranted || status.isLimited;
      }
      return false;
    } catch (e) {
      debugPrint('비디오 권한 요청 실패: $e');
      return false;
    }
  }

  // 오디오 권한 확인 및 요청
  Future<bool> _requestAudioPermission() async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.audio.status;
        // 이미 권한이 있으면 바로 리턴
        if (status.isGranted || status.isLimited) {
          return true;
        }
        // 권한이 없으면 요청
        status = await Permission.audio.request();
        return status.isGranted || status.isLimited;
      } else if (Platform.isIOS) {
        // iOS는 photos 권한으로 통합
        var status = await Permission.photos.status;
        if (status.isGranted || status.isLimited) {
          return true;
        }
        status = await Permission.photos.request();
        return status.isGranted || status.isLimited;
      }
      return false;
    } catch (e) {
      debugPrint('오디오 권한 요청 실패: $e');
      return false;
    }
  }

  // 추억 생성
  Future<void> _createMemory(
    PlaceModel place,
    String title,
    String? content,
    DateTime memoryDate,
    List<XFile> images,
    List<File> videos,
    List<File> audios,
  ) async {
    // 로딩 다이얼로그 표시
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3182F6),
        ),
      ),
    );

    try {
      final auth = ref.read(authProvider);
      if (auth is! AuthSuccess) return;
      final accessToken = auth.token.accessToken;

      final requestData = {
        'title': title,
        'content': content,
        'placeName': place.placeName,
        'memoryDate': memoryDate.toIso8601String().split('T')[0], // YYYY-MM-DD 형식
        'latitude': double.parse(place.y),
        'longitude': double.parse(place.x),
      };

      final imageFiles = images.map((xfile) => File(xfile.path)).toList();

      // 모든 파일을 하나의 리스트로 합치기
      final allFiles = <File>[
        ...imageFiles,
        ...videos,
        ...audios,
      ];

      await ref.read(memoryRepositoryProvider).createMemory(
        accessToken,
        widget.mapId,
        requestData,
        allFiles.isEmpty ? null : allFiles,
      );

      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '추억이 저장되었습니다',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF3182F6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        // 추억 목록 다시 로드
        await _loadMemories();
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.pop(context);

      if (mounted) {
        // 에러 메시지 간단하게 표시
        String errorMessage = '추억 저장 실패';
        if (e.toString().contains('Maximum upload size')) {
          errorMessage = '파일 크기가 너무 큽니다';
        } else if (e.toString().contains('network') || e.toString().contains('Network')) {
          errorMessage = '네트워크 연결을 확인해주세요';
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              '업로드 실패',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    color: Color(0xFF3182F6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  // 추억 목록 로드
  Future<void> _loadMemories() async {
    if (!mounted) return;

    try {
      final auth = ref.read(authProvider);
      if (auth is! AuthSuccess) return;
      final accessToken = auth.token.accessToken;

      final memories = await ref.read(memoryRepositoryProvider).getMemoryList(accessToken, widget.mapId);

      if (!mounted) return;

      setState(() {
        _memories = memories;
      });

      debugPrint('추억 목록 로드 완료: ${memories.length}개');
    } catch (e) {
      debugPrint('추억 목록 로드 실패: $e');
    }
  }

  // 마커 클러스터러 생성 (지도 위젯에서 사용)
  Clusterer? _createClusterer() {
    if (_memories.isEmpty) return null;

    // 마커 리스트 생성
    final markers = _memories.map((memory) =>
      Marker(
        markerId: memory.memoryId.toString(),
        latLng: LatLng(memory.latitude, memory.longitude),
        width: 30,
        height: 35,
      )
    ).toList();

    debugPrint('클러스터러 생성: 마커 ${markers.length}개');

    // 클러스터러 생성 및 반환
    return Clusterer(
      markers: markers,
      minLevel: 1, // 모든 줌 레벨에서 클러스터링 (1이 최소값)
      disableClickZoom: false, // 클러스터 클릭 시 줌인 활성화
      styles: [
        // 클러스터 스타일 (마커 개수에 따라 다른 스타일 적용 가능)
        ClustererStyle(
          width: 40,
          height: 40,
          background: const Color(0xFF3182F6), // 파란색 배경
          color: Colors.white, // 흰색 텍스트
          borderRadius: 20,
          textAlign: 'center',
          lineHeight: 40, // 텍스트 수직 중앙 정렬
        ),
      ],
    );
  }

  // 마커 클릭 이벤트 처리
  void _onMarkerTap(String markerId, LatLng latLng, int zoomLevel) {
    debugPrint('마커 클릭: $markerId at $latLng (zoom: $zoomLevel)');

    // 지도에서 해당 위치로 이동 (줌 레벨 3으로)
    mapController?.setCenter(latLng);
    mapController?.setLevel(3);

    // TODO: 마커 클릭 시 추억 상세 화면으로 이동하는 기능 구현
  }

  // 클러스터 클릭 이벤트 처리
  void _onClustererTap(LatLng latLng, int zoomLevel, List<Marker> clusterMarkers) {
    debugPrint('클러스터 클릭: ${clusterMarkers.length}개 마커 at $latLng (zoom: $zoomLevel)');

    // 클러스터 중심으로 이동하고 줌인
    mapController?.setCenter(latLng);
    mapController?.setLevel((zoomLevel - 2).clamp(1, 14)); // 최소 1, 최대 14
  }

  // 추억 목록 보기 Bottom Sheet
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
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Text(
                    '추억 목록',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3182F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_memories.length}',
                      style: const TextStyle(
                        color: Color(0xFF3182F6),
                        fontSize: 14,
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
                          Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[300]),
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
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final memory = _memories[index];
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            // 지도에서 해당 위치로 이동
                            mapController?.setCenter(LatLng(memory.latitude, memory.longitude));
                            mapController?.setLevel(3);

                            // 추억 상세 화면으로 이동
                            context.push('/map/${widget.mapId}/memory/${memory.memoryId}');
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!, width: 1),
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
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3182F6).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    color: Color(0xFF3182F6),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        memory.title,
                                        style: const TextStyle(
                                          fontSize: 17,
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
                                          const Icon(
                                            Icons.place,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              memory.placeName,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[700],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF191919), size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.mapName ?? '',
          style: const TextStyle(
            color: Color(0xFF191919),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.push(
              '/map/${widget.mapId}/settings',
              extra: {
                'mapName': widget.mapName ?? '',
                'description': widget.description,
                'memberCount': widget.memberCount,
              },
            ),
            child: const Text(
              '설정',
              style: TextStyle(
                color: Color(0xFFFF7A7A),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 카카오맵 (전체 화면 크기 지정)
          Positioned.fill(
            child: KakaoMap(
              onMapCreated: (controller) {
                mapController = controller;
                // 초기 줌 레벨 설정
                controller.setLevel(5);
              },
              center: _initialPosition,
              clusterer: _createClusterer(),
              onMarkerTap: _onMarkerTap,
              onMarkerClustererTap: _onClustererTap,
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 추억 목록 보기 버튼
          FloatingActionButton(
            heroTag: 'memory_list',
            onPressed: _showMemoryListBottomSheet,
            backgroundColor: Colors.white,
            elevation: 4,
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.list_alt,
                    color: Color(0xFF3182F6),
                    size: 28,
                  ),
                ),
                if (_memories.isNotEmpty)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3182F6),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${_memories.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}
