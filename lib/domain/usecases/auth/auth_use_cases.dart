import 'package:cat_tinder/domain/entities/auth_user.dart';
import 'package:cat_tinder/domain/repositories/analytics_repository.dart';
import 'package:cat_tinder/domain/repositories/auth_repository.dart';
import 'package:cat_tinder/domain/repositories/session_repository.dart';

const _authMethod = 'firebase_email_password';

class SignUpUseCase {
  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;
  final AnalyticsRepository _analyticsRepository;

  SignUpUseCase(
    this._authRepository,
    this._sessionRepository,
    this._analyticsRepository,
  );

  Future<void> call({required String email, required String password}) async {
    try {
      await _authRepository.register(email: email, password: password);
      await _sessionRepository.startSession(AuthUser(email: email.trim()));
      await _safeLog(
        eventName: 'signup_success',
        method: _authMethod,
      );
    } catch (error) {
      await _safeLog(
        eventName: 'signup_failed',
        method: _authMethod,
        errorType: _errorType(error),
      );
      rethrow;
    }
  }

  Future<void> _safeLog({
    required String eventName,
    required String method,
    String? errorType,
  }) async {
    try {
      await _analyticsRepository.logAuthEvent(
        eventName: eventName,
        method: method,
        errorType: errorType,
      );
    } catch (_) {}
  }

  String _errorType(Object error) {
    if (error is StateError) return 'state_error';
    return 'unknown_error';
  }
}

class SignInUseCase {
  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;
  final AnalyticsRepository _analyticsRepository;

  SignInUseCase(
    this._authRepository,
    this._sessionRepository,
    this._analyticsRepository,
  );

  Future<void> call({required String email, required String password}) async {
    final success = await _validateCredentials(email: email, password: password);
    if (!success) {
      await _safeLog(
        eventName: 'login_failed',
        method: _authMethod,
        errorType: 'invalid_credentials',
      );
      throw StateError('Invalid email or password.');
    }

    try {
      await _sessionRepository.startSession(AuthUser(email: email.trim()));
      await _safeLog(
        eventName: 'login_success',
        method: _authMethod,
      );
    } catch (error) {
      await _safeLog(
        eventName: 'login_failed',
        method: _authMethod,
        errorType: _errorType(error),
      );
      rethrow;
    }
  }

  Future<bool> _validateCredentials({
    required String email,
    required String password,
  }) async {
    try {
      return await _authRepository.validateCredentials(
        email: email,
        password: password,
      );
    } catch (error) {
      await _safeLog(
        eventName: 'login_failed',
        method: _authMethod,
        errorType: _errorType(error),
      );
      rethrow;
    }
  }

  Future<void> _safeLog({
    required String eventName,
    required String method,
    String? errorType,
  }) async {
    try {
      await _analyticsRepository.logAuthEvent(
        eventName: eventName,
        method: method,
        errorType: errorType,
      );
    } catch (_) {}
  }

  String _errorType(Object error) {
    if (error is StateError) return 'state_error';
    return 'unknown_error';
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
