import 'package:cat_tinder/domain/entities/auth_user.dart';
import 'package:cat_tinder/domain/repositories/auth_repository.dart';
import 'package:cat_tinder/domain/repositories/session_repository.dart';

class SignUpUseCase {
  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;

  SignUpUseCase(this._authRepository, this._sessionRepository);

  Future<void> call({required String email, required String password}) async {
    await _authRepository.register(email: email, password: password);
    await _sessionRepository.startSession(AuthUser(email: email.trim()));
  }
}

class SignInUseCase {
  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;

  SignInUseCase(this._authRepository, this._sessionRepository);

  Future<void> call({required String email, required String password}) async {
    final success = await _authRepository.validateCredentials(
      email: email,
      password: password,
    );
    if (!success) {
      throw StateError('Invalid email or password.');
    }
    await _sessionRepository.startSession(AuthUser(email: email.trim()));
  }
}

class SignOutUseCase {
  final SessionRepository _sessionRepository;

  SignOutUseCase(this._sessionRepository);

  Future<void> call() {
    return _sessionRepository.endSession();
  }
}

class IsAuthorizedUseCase {
  final SessionRepository _sessionRepository;

  IsAuthorizedUseCase(this._sessionRepository);

  Future<bool> call() {
    return _sessionRepository.isAuthorized();
  }
}

class GetCurrentUserUseCase {
  final SessionRepository _sessionRepository;

  GetCurrentUserUseCase(this._sessionRepository);

  Future<AuthUser?> call() {
    return _sessionRepository.currentUser();
  }
}
