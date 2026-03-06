import 'package:cat_tinder/data/auth/firebase_auth_service.dart';
import 'package:cat_tinder/domain/entities/auth_user.dart';
import 'package:cat_tinder/domain/repositories/session_repository.dart';

class FirebaseSessionRepository implements SessionRepository {
  final FirebaseAuthService _service;

  FirebaseSessionRepository(this._service);

  @override
  Future<void> startSession(AuthUser user) async {
    final current = _service.currentUser;
    if (current == null) {
      throw StateError('Failed to start session.');
    }
  }

  @override
  Future<void> endSession() async {
    await _service.signOut();
  }

  @override
  Future<bool> isAuthorized() async {
    return _service.currentUser != null;
  }

  @override
  Future<AuthUser?> currentUser() async {
    final user = _service.currentUser;
    final email = user?.email;
    if (email == null || email.isEmpty) {
      return null;
    }
    return AuthUser(email: email);
  }
}
