import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/models/place_model.dart';

class PlaceSearchScreen extends StatefulWidget {
  const PlaceSearchScreen({super.key});

  @override
  State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Dio _dio = Dio();
  Timer? _debounce;

  List<PlaceModel> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(query));
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isSearching = true);
    try {
      final key = dotenv.env['KAKAO_REST_API_KEY'] ?? '';
      final response = await _dio.get(
        'https://dapi.kakao.com/v2/local/search/keyword.json',
        queryParameters: {'query': query},
        options: Options(headers: {'Authorization': 'KakaoAK $key'}),
      );
      final docs = response.data['documents'] as List;
      if (mounted) {
        setState(() {
          _results =
              docs.map((d) => PlaceModel.fromJson(d as Map<String, dynamic>)).toList();
          _hasSearched = true;
        });
      }
    } catch (_) {
      // 검색 실패 시 결과 유지
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _select(PlaceModel place) {
    Navigator.pop(context, {
      'name': place.placeName,
      'address': place.addressName,
      'latitude': double.tryParse(place.y) ?? 37.5665,
      'longitude': double.tryParse(place.x) ?? 126.9780,
    });
  }

  String _extractCategory(String categoryName) {
    if (categoryName.isEmpty) return '';
    final parts = categoryName.split(' > ');
    return parts.last.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더 + 검색창
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFDFBF7),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF0ECE8), width: 1),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text(
                        '◀',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFFAAAAAA),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 15),
                          const Text('🔍', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              onChanged: _onChanged,
                              onSubmitted: _search,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_isSearching)
                            const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFFF8E8E),
                                ),
                              ),
                            )
                          else if (_controller.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _controller.clear();
                                setState(() {
                                  _results = [];
                                  _hasSearched = false;
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Color(0xFFAAAAAA),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 검색 결과
            Expanded(
              child: _isSearching && _results.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF8E8E),
                      ),
                    )
                  : !_hasSearched
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '🔍',
                                style: TextStyle(
                                  fontSize: 48,
                                  color: Colors.grey[300],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '장소명을 입력하면 검색됩니다',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _results.isEmpty
                          ? Center(
                              child: Text(
                                '검색 결과가 없습니다',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                              itemCount: _results.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      '검색 결과 ${_results.length}개',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF888888),
                                      ),
                                    ),
                                  );
                                }
                                final place = _results[index - 1];
                                final category =
                                    _extractCategory(place.categoryName);
                                return GestureDetector(
                                  onTap: () => _select(place),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 14, 16, 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                              alpha: 0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          place.placeName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          place.addressName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF888888),
                                          ),
                                        ),
                                        if (category.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            '· $category',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFFF8E8E),
                                            ),
                                          ),
                                        ],
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
}
