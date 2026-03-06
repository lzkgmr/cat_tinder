import 'package:cat_tinder/domain/entities/breed.dart';
import 'package:cat_tinder/domain/entities/cat.dart';
import 'package:cat_tinder/domain/repositories/cat_repository.dart';

class FetchCatsStreamUseCase {
  final CatRepository _repository;

  FetchCatsStreamUseCase(this._repository);

  Stream<Cat> call({int limit = 10}) {
    return _repository.fetchCatsStream(limit: limit);
  }
}

class FetchBreedsUseCase {
  final CatRepository _repository;

  FetchBreedsUseCase(this._repository);

  Future<List<Breed>> call() {
    return _repository.fetchBreeds();
  }
}

class FetchBreedByIdUseCase {
  final CatRepository _repository;

  FetchBreedByIdUseCase(this._repository);

  Future<Breed?> call(String id) {
    return _repository.fetchBreedById(id);
  }
}
