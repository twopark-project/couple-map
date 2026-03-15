import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/memory_model.dart';

class MemoryRepository {
  // 추억 목록 조회
  Future<List<MemorySummary>> getMemoryList(String accessToken, int mapId) async {
    try {
      final response = await DioClient.instance.get(
        '/api/maps/$mapId/memories',
        options: DioClient.authOptions(accessToken),
      );
      final data = response.data['data'];
      if (data == null) return [];
      return (data as List)
          .map((json) => MemorySummary.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // 추억 상세 조회
  Future<MemoryModel> getMemoryDetail(String accessToken, int mapId, int memoryId) async {
    try {
      final response = await DioClient.instance.get(
        '/api/maps/$mapId/memories/$memoryId',
        options: DioClient.authOptions(accessToken),
      );
      return MemoryModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // 추억 생성
  Future<int> createMemory(
    String accessToken,
    int mapId,
    Map<String, dynamic> requestData,
    List<File>? imageFiles,
  ) async {
    try {
      final formData = FormData();
      formData.files.add(MapEntry(
        'request',
        MultipartFile.fromString(
          jsonEncode(requestData),
          contentType: DioMediaType.parse('application/json'),
        ),
      ));
      if (imageFiles != null) {
        for (final file in imageFiles) {
          formData.files.add(MapEntry(
            'files',
            await MultipartFile.fromFile(file.path,
                filename: file.path.split('/').last),
          ));
        }
      }
      final response = await DioClient.instance.post(
        '/api/maps/$mapId/memories',
        data: formData,
        options: DioClient.authOptions(accessToken),
      );
      return response.data['data'] as int;
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    }
  }
}
