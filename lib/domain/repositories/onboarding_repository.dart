abstract class OnboardingRepository {
  Future<bool> isCompleted();

  Future<void> setCompleted(bool value);
}
