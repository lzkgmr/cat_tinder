import 'package:cat_tinder/domain/entities/cat.dart';

abstract class LikesRepository {
  Future<int> getLikesCount();

  Future<void> setLikesCount(int value);

  Future<List<Cat>> getLikedCats();

  Future<void> addLikedCat(Cat cat);

  Future<void> removeLikedCat(String catId);

  Future<void> clearLikedCats();
}
