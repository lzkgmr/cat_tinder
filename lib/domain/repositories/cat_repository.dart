import 'package:cat_tinder/domain/entities/breed.dart';
import 'package:cat_tinder/domain/entities/cat.dart';

abstract class CatRepository {
  Stream<Cat> fetchCatsStream({int limit = 10});

  Future<List<Breed>> fetchBreeds();

  Future<Breed?> fetchBreedById(String id);
}
