import 'package:cat_tinder/domain/entities/cat.dart';
import 'package:cat_tinder/domain/usecases/likes/likes_use_cases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'liked_cats_state.dart';

class LikedCatsCubit extends Cubit<LikedCatsState> {
  final GetLikedCatsUseCase _getLikedCats;
  final RemoveLikedCatUseCase _removeLikedCat;
  final ClearLikedCatsUseCase _clearLikedCats;

  LikedCatsCubit({
    required GetLikedCatsUseCase getLikedCats,
    required RemoveLikedCatUseCase removeLikedCat,
    required ClearLikedCatsUseCase clearLikedCats,
  }) : _getLikedCats = getLikedCats,
       _removeLikedCat = removeLikedCat,
       _clearLikedCats = clearLikedCats,
       super(LikedCatsState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final cats = await _getLikedCats();
      emit(state.copyWith(isLoading: false, cats: cats));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: '$e'));
    }
  }

  Future<void> remove(Cat cat) async {
    final updated = List<Cat>.from(state.cats)
      ..removeWhere((current) => current.id == cat.id);
    emit(state.copyWith(cats: updated));
    await _removeLikedCat(cat.id);
  }

  Future<void> clear() async {
    await _clearLikedCats();
    emit(state.copyWith(cats: <Cat>[]));
  }
}
