import 'dart:async';
import 'package:dio/dio.dart';
import '../models/breed.dart';
import '../models/cat_image.dart';
import '../handling/error_handling.dart';

class CatApiService {
  static const _baseUrl = 'https://api.thecatapi.com/v1';
  final Dio _dio;

  CatApiService({String? apiKey, Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: apiKey != null ? {'x-api-key': apiKey} : null,
            ));

  Future<CatImage> fetchRandomCat({String? breedId}) async {
    try {
      final query = <String, dynamic>{
        'limit': 1,
        'size': 'med',
        'has_breeds': 1,
      };
      if (breedId != null) query['breed_ids'] = breedId;

      final resp = await _dio.get('/images/search', queryParameters: query);
      if (resp.statusCode == 200 && resp.data is List && (resp.data as List).isNotEmpty) {
        final first = (resp.data as List).first as Map<String, dynamic>;
        return CatImage.fromJson(first);
      } else {
        throw ApiException('Empty response from images/search', resp.statusCode);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message;
      throw ApiException('Failed to fetch random cat: $msg', e.response?.statusCode);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<List<Breed>> fetchBreeds() async {
    try {
      final resp = await _dio.get('/breeds');

      if (resp.statusCode == 200 && resp.data is List) {
        final list = resp.data as List;
        return list.map((e) => Breed.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw ApiException('Empty response from breeds', resp.statusCode);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message;
      throw ApiException('Failed to fetch breeds: $msg', e.response?.statusCode);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<Breed?> fetchBreedById(String id) async {
    final breeds = await fetchBreeds();
    try {
      return breeds.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
