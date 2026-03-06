import 'package:cat_tinder/domain/usecases/cats/cat_use_cases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'breeds_state.dart';

class BreedsCubit extends Cubit<BreedsState> {
  final FetchBreedsUseCase _fetchBreeds;

  BreedsCubit({required FetchBreedsUseCase fetchBreeds})
    : _fetchBreeds = fetchBreeds,
      super(BreedsState.initial());

  Future<void> loadBreeds() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final breeds = await _fetchBreeds();
      emit(state.copyWith(isLoading: false, breeds: breeds));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: '$e'));
    }
  }
}
