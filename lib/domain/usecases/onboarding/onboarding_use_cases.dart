import 'package:cat_tinder/domain/repositories/onboarding_repository.dart';

class IsOnboardingCompletedUseCase {
  final OnboardingRepository _repository;

  IsOnboardingCompletedUseCase(this._repository);

  Future<bool> call() {
    return _repository.isCompleted();
  }
}

class CompleteOnboardingUseCase {
  final OnboardingRepository _repository;

  CompleteOnboardingUseCase(this._repository);

  Future<void> call() {
    return _repository.setCompleted(true);
  }
}
