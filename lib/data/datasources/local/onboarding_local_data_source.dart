import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingLocalDataSource {
  Future<bool> readCompleted();

  Future<void> writeCompleted(bool value);
}

class SharedPrefsOnboardingLocalDataSource implements OnboardingLocalDataSource {
  static const _onboardingCompletedKey = 'onboarding_completed';
  final SharedPreferences _prefs;

  SharedPrefsOnboardingLocalDataSource(this._prefs);

  @override
  Future<bool> readCompleted() async {
    return _prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  @override
  Future<void> writeCompleted(bool value) async {
    await _prefs.setBool(_onboardingCompletedKey, value);
  }
}
