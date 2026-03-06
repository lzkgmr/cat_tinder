import 'package:cat_tinder/data/datasources/local/storage_service.dart';
import 'package:cat_tinder/domain/entities/cat.dart';
import 'package:cat_tinder/domain/repositories/likes_repository.dart';

class LocalLikesRepository implements LikesRepository {
  final StorageService _storage;

  LocalLikesRepository(this._storage);

  @override
  Future<int> getLikesCount() async {
    return _storage.getLikes();
  }

  @override
  Future<void> setLikesCount(int value) async {
    await _storage.setLikes(value);
  }

  @override
  Future<List<Cat>> getLikedCats() async {
    return _storage.getLikedCats();
  }

  @override
  Future<void> addLikedCat(Cat cat) async {
    await _storage.addLikedCat(cat);
  }

  @override
  Future<void> removeLikedCat(String catId) async {
    await _storage.removeLikedCat(catId);
  }

  @override
  Future<void> clearLikedCats() async {
    await _storage.clearLikedCats();
  }
}
