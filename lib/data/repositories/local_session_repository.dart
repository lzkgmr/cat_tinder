import 'package:cat_tinder/data/datasources/local/session_local_data_source.dart';
import 'package:cat_tinder/domain/entities/auth_user.dart';
import 'package:cat_tinder/domain/repositories/session_repository.dart';

class LocalSessionRepository implements SessionRepository {
  final SessionLocalDataSource _localDataSource;

  LocalSessionRepository(this._localDataSource);

  @override
  Future<void> startSession(AuthUser user) async {
    await _localDataSource.saveCurrentUserEmail(user.email.trim().toLowerCase());
  }

  @override
  Future<void> endSession() async {
    await _localDataSource.clearCurrentUserEmail();
  }

  @override
  Future<bool> isAuthorized() async {
    return await _localDataSource.getCurrentUserEmail() != null;
  }

  @override
  Future<AuthUser?> currentUser() async {
    final email = await _localDataSource.getCurrentUserEmail();
    if (email == null || email.isEmpty) {
      return null;
    }
    return AuthUser(email: email);
  }
}
