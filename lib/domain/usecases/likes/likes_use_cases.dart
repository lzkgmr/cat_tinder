import 'package:cat_tinder/domain/entities/cat.dart';
import 'package:cat_tinder/domain/repositories/likes_repository.dart';

class GetLikesCountUseCase {
  final LikesRepository _repository;

  GetLikesCountUseCase(this._repository);

  Future<int> call() {
    return _repository.getLikesCount();
  }
}

class SetLikesCountUseCase {
  final LikesRepository _repository;

  SetLikesCountUseCase(this._repository);

  Future<void> call(int value) {
    return _repository.setLikesCount(value);
  }
}

class GetLikedCatsUseCase {
  final LikesRepository _repository;

  GetLikedCatsUseCase(this._repository);

  Future<List<Cat>> call() {
    return _repository.getLikedCats();
  }
}

class AddLikedCatUseCase {
  final LikesRepository _repository;

  AddLikedCatUseCase(this._repository);

  Future<void> call(Cat cat) {
    return _repository.addLikedCat(cat);
  }
}

class RemoveLikedCatUseCase {
  final LikesRepository _repository;

  RemoveLikedCatUseCase(this._repository);

  Future<void> call(String catId) {
    return _repository.removeLikedCat(catId);
  }
}

class ClearLikedCatsUseCase {
  final LikesRepository _repository;

  ClearLikedCatsUseCase(this._repository);

  Future<void> call() {
    return _repository.clearLikedCats();
  }
}
