import 'package:cat_tinder/data/datasources/remote/cat_remote_data_source.dart';
import 'package:cat_tinder/domain/entities/breed.dart';
import 'package:cat_tinder/domain/entities/cat.dart';
import 'package:cat_tinder/domain/repositories/cat_repository.dart';

class ApiCatRepository implements CatRepository {
  final CatRemoteDataSource _remoteDataSource;

  ApiCatRepository({required CatRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Stream<Cat> fetchCatsStream({int limit = 10}) {
    return _remoteDataSource.fetchCatsStream(limit: limit);
  }

  @override
  Future<List<Breed>> fetchBreeds() {
    return _remoteDataSource.fetchBreeds();
  }

  @override
  Future<Breed?> fetchBreedById(String id) {
    return _remoteDataSource.fetchBreedById(id);
  }
}
