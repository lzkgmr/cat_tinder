import 'dart:convert';
import 'package:cat_tinder/models/cat.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/breed.dart';

class CatApiService {
  static const _baseUrl = 'https://api.thecatapi.com/v1';
  final String? apiKey;
  final Connectivity connectivity;

  final Set<String> _loadedCatIds = {};

  CatApiService({this.apiKey, Connectivity? connectivity})
    : connectivity = connectivity ?? Connectivity();

  Future<List<Cat>> fetchCats({int limit = 10}) async {
    final connectivityResult = await connectivity.checkConnectivity();
    
    // ignore: unrelated_type_equality_checks
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('No internet connection');
    }

    List<Cat> cats = await _fetchFromRemote(limit);

    cats = cats.where((cat) => !_loadedCatIds.contains(cat.id)).toList();
    for (var cat in cats) {
      _loadedCatIds.add(cat.id);
    }

    await _precacheAllImages(cats);
    return cats;
  }

  Future<void> _precacheAllImages(List<Cat> cats) async {
    final cacheManager = DefaultCacheManager();
    final tasks = cats.map((cat) async {
      try {
        await cacheManager.downloadFile(cat.imageUrl);
      } catch (e) {
        if (kDebugMode) print('Failed to cache ${cat.imageUrl}: $e');
      }
    });
    await Future.wait(tasks);
  }

  Future<List<Cat>> _fetchFromRemote(int limit) async {
    int attempts = 0;
    while (attempts < 5) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/images/search?limit=$limit&has_breeds=1'),
          headers: apiKey != null ? {'x-api-key': apiKey!} : null,
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          final cats = <Cat>[];

          for (var image in data) {
            final cat = await _fetchCatDetails(image['id']);
            if (cat != null) cats.add(cat);
          }

          if (cats.isEmpty) throw Exception('No cats with breed info found');
          return cats;
        } else {
          if (kDebugMode) {
            print('HTTP ${response.statusCode}: ${response.body}');
          }
        }
      } catch (e) {
        if (kDebugMode) print('Attempt $attempts failed: $e');
      }
      attempts++;
    }

    throw Exception('Failed to load cats after multiple attempts');
  }

  Future<Cat?> _fetchCatDetails(String imageId) async {
    int attempts = 0;
    while (attempts < 5) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/images/$imageId'),
          headers: apiKey != null ? {'x-api-key': apiKey!} : null,
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> detailData = json.decode(response.body);
          final List<dynamic> breeds = detailData['breeds'] ?? [];

          if (breeds.isNotEmpty && detailData['url'] != null) {
            final breed = breeds[0];
            return Cat(
              id: detailData['id'],
              imageUrl: detailData['url'],
              breed: breed['name'],
              description: breed['description'] ?? 'No description available',
              temperament: breed['temperament'] ?? 'No temperament info',
              origin: breed['origin'] ?? 'Unknown origin',
              lifeSpan: breed['life_span'] ?? 'Unknown',
              wikipediaUrl: breed['wikipedia_url'] ?? '',
              breedId: breed['id'] ?? '',
            );
          }
        }
      } catch (e) {
        if (kDebugMode) print('Error fetching cat details $imageId: $e');
      }
      attempts++;
    }

    return Cat(
      id: 'placeholder_${DateTime.now().millisecondsSinceEpoch}',
      imageUrl: 'https://via.placeholder.com/400',
      breed: 'Не удалось загрузить',
      description: 'Не удалось загрузить',
      temperament: 'Не удалось загрузить',
      origin: 'Не удалось загрузить',
      lifeSpan: 'Не удалось загрузить',
      wikipediaUrl: '',
      breedId: '',
    );
  }

  Future<List<Breed>> fetchBreeds() async {
    int attempts = 0;
    // breeds with 403 error trying to get images
    final excludedIds = {'asho', 'beng', 'drex', 'ebur', 'kora', 'mala'};
    while (attempts < 5) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/breeds'),
          headers: apiKey != null ? {'x-api-key': apiKey!} : null,
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);

          final List<Breed> breeds = data.map((item) {
            return Breed(
              id: item['id'] ?? '',
              name: item['name'] ?? '',
              description: item['description'] ?? 'No description available',
              temperament: item['temperament'] ?? 'No temperament info',
              origin: item['origin'] ?? 'Unknown origin',
              lifeSpan: item['life_span'] ?? 'Unknown',
              weightMetric: item['weight']?['metric'],
              adaptability: item['adaptability'] is int
                  ? item['adaptability'] as int
                  : null,
              intelligence: item['intelligence'] is int
                  ? item['intelligence'] as int
                  : null,
              imageUrl: item['reference_image_id'] != null
                  ? 'https://cdn2.thecatapi.com/images/${item['reference_image_id']}.jpg'
                  : null,
              countryCode: item['country_code'] ?? '',
            );
          }).toList();

          final filtered = breeds
              .where((b) => !excludedIds.contains(b.id))
              .toList();

          return filtered;
        } else {
          if (kDebugMode) {
            print('HTTP ${response.statusCode}: ${response.body}');
          }
        }
      } catch (e) {
        if (kDebugMode) print('Attempt $attempts to load breeds failed: $e');
      }

      attempts++;
    }

    throw Exception('Failed to load breeds after multiple attempts');
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
