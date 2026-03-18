import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/place_model.dart';

class PlaceSearchScreen extends StatefulWidget {
  const PlaceSearchScreen({super.key});

  @override
  State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final Dio _dio = Dio();
  Timer? _debounce;

  List<PlaceModel> _results = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(query));
  }

  Future<void> _search(String query) async {
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
          _results = docs
              .map((d) => PlaceModel.fromJson(d as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (_) {
      // 검색 실패 시 결과 유지
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _select(PlaceModel place) {
    context.pop({
      'name': place.placeName,
      'latitude': double.tryParse(place.y) ?? 37.5665,
      'longitude': double.tryParse(place.x) ?? 126.9780,
    });
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
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          onSubmitted: _search,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: '장소를 검색하세요',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            border: InputBorder.none,
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF3182F6),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
      body: _results.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    '장소명을 입력하면 검색됩니다',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final place = _results[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3182F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.place,
                      color: Color(0xFF3182F6),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    place.placeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    place.addressName,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  onTap: () => _select(place),
                );
              },
            ),
    );
  }
}
