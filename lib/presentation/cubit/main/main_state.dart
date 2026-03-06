import 'package:cat_tinder/domain/entities/cat.dart';

class MainState {
  final List<Cat> cats;
  final int currentIndex;
  final int likesCount;
  final bool isLoading;
  final String? errorMessage;

  const MainState({
    required this.cats,
    required this.currentIndex,
    required this.likesCount,
    required this.isLoading,
    this.errorMessage,
  });

  factory MainState.initial() {
    return const MainState(
      cats: <Cat>[],
      currentIndex: 0,
      likesCount: 0,
      isLoading: true,
      errorMessage: null,
    );
  }

  Cat? get currentCat {
    if (cats.isEmpty || currentIndex < 0 || currentIndex >= cats.length) {
      return null;
    }
    return cats[currentIndex];
  }

  MainState copyWith({
    List<Cat>? cats,
    int? currentIndex,
    int? likesCount,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MainState(
      cats: cats ?? this.cats,
      currentIndex: currentIndex ?? this.currentIndex,
      likesCount: likesCount ?? this.likesCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
