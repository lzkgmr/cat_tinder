import 'package:cat_tinder/domain/entities/breed.dart';
import 'package:cat_tinder/domain/entities/cat.dart';
import 'package:cat_tinder/domain/usecases/cats/cat_use_cases.dart';
import 'package:cat_tinder/domain/usecases/likes/likes_use_cases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  final FetchCatsStreamUseCase _fetchCatsStream;
  final FetchBreedByIdUseCase _fetchBreedById;
  final GetLikesCountUseCase _getLikesCount;
  final SetLikesCountUseCase _setLikesCount;
  final AddLikedCatUseCase _addLikedCat;

  bool _isLoadingCats = false;

  MainCubit({
    required FetchCatsStreamUseCase fetchCatsStream,
    required FetchBreedByIdUseCase fetchBreedById,
    required GetLikesCountUseCase getLikesCount,
    required SetLikesCountUseCase setLikesCount,
    required AddLikedCatUseCase addLikedCat,
  }) : _fetchCatsStream = fetchCatsStream,
       _fetchBreedById = fetchBreedById,
       _getLikesCount = getLikesCount,
       _setLikesCount = setLikesCount,
       _addLikedCat = addLikedCat,
       super(MainState.initial());

  Future<void> initialize() async {
    final likes = await _getLikesCount();
    emit(state.copyWith(likesCount: likes, isLoading: state.cats.isEmpty));
    await loadMoreCatsIfNeeded(force: true);
  }

  Future<void> refreshLikes() async {
    final likes = await _getLikesCount();
    emit(state.copyWith(likesCount: likes));
  }

  Future<void> loadMoreCatsIfNeeded({bool force = false}) async {
    if (_isLoadingCats) return;
    final remaining = state.cats.length - state.currentIndex;
    if (!force && remaining > 4) return;

    _isLoadingCats = true;
    emit(state.copyWith(isLoading: state.cats.isEmpty, clearError: true));

    try {
      await for (final cat in _fetchCatsStream(limit: 10)) {
        final updatedCats = List<Cat>.from(state.cats)..add(cat);
        emit(state.copyWith(cats: updatedCats, isLoading: false));
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load cats: $e',
        ),
      );
    } finally {
      _isLoadingCats = false;
    }
  }

  Future<void> handleSwipe({
    required int previousIndex,
    required int? nextIndex,
    required bool liked,
  }) async {
    if (previousIndex < 0 || previousIndex >= state.cats.length) {
      return;
    }

    if (liked) {
      final cat = state.cats[previousIndex];
      final newLikes = state.likesCount + 1;
      emit(state.copyWith(likesCount: newLikes));

      await _setLikesCount(newLikes);
      await _addLikedCat(cat);
    }

    if (nextIndex != null) {
      emit(state.copyWith(currentIndex: nextIndex));
      await loadMoreCatsIfNeeded();
    }
  }

  void handleUndo(int currentIndex) {
    emit(state.copyWith(currentIndex: currentIndex));
  }

  Future<Breed?> loadCurrentBreed() async {
    final currentCat = state.currentCat;
    if (currentCat == null || currentCat.breedId.isEmpty) {
      return null;
    }
    return _fetchBreedById(currentCat.breedId);
  }
}
