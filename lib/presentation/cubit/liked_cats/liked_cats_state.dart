import 'package:cat_tinder/domain/entities/cat.dart';

class LikedCatsState {
  final bool isLoading;
  final List<Cat> cats;
  final String? errorMessage;

  const LikedCatsState({
    required this.isLoading,
    required this.cats,
    this.errorMessage,
  });

  factory LikedCatsState.initial() {
    return const LikedCatsState(isLoading: true, cats: <Cat>[]);
  }

  LikedCatsState copyWith({
    bool? isLoading,
    List<Cat>? cats,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LikedCatsState(
      isLoading: isLoading ?? this.isLoading,
      cats: cats ?? this.cats,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
