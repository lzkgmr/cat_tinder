import 'package:cat_tinder/domain/entities/auth_user.dart';

abstract class SessionRepository {
  Future<void> startSession(AuthUser user);

  Future<void> endSession();

  Future<bool> isAuthorized();

  Future<AuthUser?> currentUser();
}
