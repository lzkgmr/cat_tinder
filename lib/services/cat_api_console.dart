import '../services/cat_api_service.dart';

/// Утилиты для проверки CatApiService в консоли
class CatApiConsole {
  final CatApiService api;

  CatApiConsole(this.api);

  /// Показать одну случайную картинку котика
  Future<void> showRandomCat({String? breedId}) async {
    try {
      final cat = await api.fetchRandomCat(breedId: breedId);
      print('--- Random Cat ---');
      print('ID: ${cat.id}');
      print('URL: ${cat.url}');
      print('Size: ${cat.width} x ${cat.height}');
      if (cat.breeds.isNotEmpty) {
        final breed = cat.breeds.first;
        print('Breed: ${breed.name}');
        print('Temperament: ${breed.temperament}');
      } else {
        print('No breed info available.');
      }
      print('-----------------');
    } catch (e) {
      print('Error fetching random cat: $e');
    }
  }

  /// Показать список всех пород
  Future<void> showAllBreeds({int limit = 10}) async {
    try {
      final breeds = await api.fetchBreeds();
      print('--- Breeds (showing up to $limit) ---');
      for (var i = 0; i < breeds.length && i < limit; i++) {
        final b = breeds[i];
        print('${i + 1}. ${b.name} (${b.origin ?? "unknown"})');
        print('   Life span: ${b.lifeSpan ?? "N/A"}');
        print('   Weight: ${b.weightMetric ?? "N/A"} kg');
        print('   Adaptability: ${b.adaptability ?? "N/A"}');
        print('   Intelligence: ${b.intelligence ?? "N/A"}');
        print('----------------------');
      }
    } catch (e) {
      print('Error fetching breeds: $e');
    }
  }

  /// Показать детальную информацию по породе по ID
  Future<void> showBreedDetails(String breedId) async {
    try {
      final breed = await api.fetchBreedById(breedId);
      if (breed == null) {
        print('Breed with id "$breedId" not found.');
        return;
      }
      print('--- Breed Details ---');
      print('Name: ${breed.name}');
      print('Origin: ${breed.origin ?? "N/A"}');
      print('Temperament: ${breed.temperament ?? "N/A"}');
      print('Life span: ${breed.lifeSpan ?? "N/A"}');
      print('Weight: ${breed.weightMetric ?? "N/A"} kg');
      print('Adaptability: ${breed.adaptability ?? "N/A"}');
      print('Intelligence: ${breed.intelligence ?? "N/A"}');
      print('Description: ${breed.description ?? "N/A"}');
      print('Image URL: ${breed.imageUrl ?? "N/A"}');
      print('--------------------');
    } catch (e) {
      print('Error fetching breed details: $e');
    }
  }
}
