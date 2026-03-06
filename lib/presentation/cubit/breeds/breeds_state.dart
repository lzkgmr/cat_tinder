import 'package:cat_tinder/domain/entities/breed.dart';

class BreedsState {
  final bool isLoading;
  final List<Breed> breeds;
  final String? errorMessage;

  const BreedsState({
    required this.isLoading,
    required this.breeds,
    this.errorMessage,
  });

  factory BreedsState.initial() {
    return const BreedsState(isLoading: true, breeds: <Breed>[]);
  }

  BreedsState copyWith({
    bool? isLoading,
    List<Breed>? breeds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BreedsState(
      isLoading: isLoading ?? this.isLoading,
      breeds: breeds ?? this.breeds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
