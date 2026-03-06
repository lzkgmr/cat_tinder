import 'package:cat_tinder/data/datasources/local/onboarding_local_data_source.dart';
import 'package:cat_tinder/domain/repositories/onboarding_repository.dart';

class LocalOnboardingRepository implements OnboardingRepository {
  final OnboardingLocalDataSource _localDataSource;

  LocalOnboardingRepository(this._localDataSource);

  @override
  Future<bool> isCompleted() async {
    return _localDataSource.readCompleted();
  }

  @override
  Future<void> setCompleted(bool value) async {
    await _localDataSource.writeCompleted(value);
  }
}
