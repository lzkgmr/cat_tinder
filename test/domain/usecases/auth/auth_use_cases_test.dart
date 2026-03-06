import 'package:cat_tinder/domain/entities/auth_user.dart';
import 'package:cat_tinder/domain/repositories/analytics_repository.dart';
import 'package:cat_tinder/domain/repositories/auth_repository.dart';
import 'package:cat_tinder/domain/repositories/session_repository.dart';
import 'package:cat_tinder/domain/usecases/auth/auth_use_cases.dart';
import 'package:cat_tinder/domain/usecases/auth/validate_auth_input_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSessionRepository extends Mock implements SessionRepository {}

class _MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

class _FakeAuthUser extends Fake implements AuthUser {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeAuthUser());
  });

  group('ValidateAuthInputUseCase', () {
    final useCase = ValidateAuthInputUseCase();

    test('returns valid result for correct email and password', () {
      final result = useCase(
        email: 'cat@example.com',
        password: 'secure123',
      );

      expect(result.isValid, isTrue);
      expect(result.emailError, isNull);
      expect(result.passwordError, isNull);
    });

    test('returns errors for invalid email and short password', () {
      final result = useCase(
        email: 'wrong-email',
        password: '123',
      );

      expect(result.isValid, isFalse);
      expect(result.emailError, 'Invalid email format');
      expect(result.passwordError, 'Password must be at least 6 characters');
    });
  });

  group('SignInUseCase', () {
    late _MockAuthRepository authRepository;
    late _MockSessionRepository sessionRepository;
    late _MockAnalyticsRepository analyticsRepository;
    late SignInUseCase useCase;

    setUp(() {
      authRepository = _MockAuthRepository();
      sessionRepository = _MockSessionRepository();
      analyticsRepository = _MockAnalyticsRepository();

      when(
        () => analyticsRepository.logAuthEvent(
          eventName: any(named: 'eventName'),
          method: any(named: 'method'),
          errorType: any(named: 'errorType'),
        ),
      ).thenAnswer((_) async {});

      useCase = SignInUseCase(
        authRepository,
        sessionRepository,
        analyticsRepository,
      );
    });

    test('successful sign in starts session', () async {
      when(
        () => authRepository.validateCredentials(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => true);
      when(() => sessionRepository.startSession(any())).thenAnswer((_) async {});

      await useCase(email: '  cat@example.com  ', password: 'secure123');

      verify(
        () => authRepository.validateCredentials(
          email: '  cat@example.com  ',
          password: 'secure123',
        ),
      ).called(1);
      verify(
        () => sessionRepository.startSession(
          any(
            that: isA<AuthUser>().having(
              (user) => user.email,
              'email',
              'cat@example.com',
            ),
          ),
        ),
      ).called(1);
    });

    test('failed sign in does not start session', () async {
      when(
        () => authRepository.validateCredentials(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => false);

      expect(
        () => useCase(email: 'cat@example.com', password: 'bad'),
        throwsA(isA<StateError>()),
      );

      verifyNever(() => sessionRepository.startSession(any()));
    });
  });
}
