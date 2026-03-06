import 'package:cat_tinder/di/di_container.dart';
import 'package:cat_tinder/domain/entities/auth_user.dart';
import 'package:cat_tinder/domain/entities/breed.dart';
import 'package:cat_tinder/domain/entities/cat.dart';
import 'package:cat_tinder/domain/repositories/analytics_repository.dart';
import 'package:cat_tinder/domain/repositories/auth_repository.dart';
import 'package:cat_tinder/domain/repositories/cat_repository.dart';
import 'package:cat_tinder/domain/repositories/likes_repository.dart';
import 'package:cat_tinder/domain/repositories/session_repository.dart';
import 'package:cat_tinder/domain/usecases/auth/auth_use_cases.dart';
import 'package:cat_tinder/domain/usecases/cats/cat_use_cases.dart';
import 'package:cat_tinder/domain/usecases/likes/likes_use_cases.dart';
import 'package:cat_tinder/presentation/cubit/auth/auth_cubit.dart';
import 'package:cat_tinder/presentation/cubit/main/main_cubit.dart';
import 'package:cat_tinder/presentation/screens/login_screen.dart';
import 'package:cat_tinder/presentation/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppDiContainer extends Mock implements AppDiContainer {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSessionRepository extends Mock implements SessionRepository {}

class _MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

class _FakeAuthUser extends Fake implements AuthUser {}

class _FakeCatRepository implements CatRepository {
  @override
  Stream<Cat> fetchCatsStream({int limit = 10}) => const Stream.empty();

  @override
  Future<List<Breed>> fetchBreeds() async => <Breed>[];

  @override
  Future<Breed?> fetchBreedById(String id) async => null;
}

class _FakeLikesRepository implements LikesRepository {
  @override
  Future<void> addLikedCat(Cat cat) async {}

  @override
  Future<void> clearLikedCats() async {}

  @override
  Future<List<Cat>> getLikedCats() async => <Cat>[];

  @override
  Future<int> getLikesCount() async => 0;

  @override
  Future<void> removeLikedCat(String catId) async {}

  @override
  Future<void> setLikesCount(int value) async {}
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeAuthUser());
  });

  late _MockAppDiContainer di;
  late _MockAuthRepository authRepository;
  late _MockSessionRepository sessionRepository;
  late _MockAnalyticsRepository analyticsRepository;

  setUp(() {
    di = _MockAppDiContainer();
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
  });

  Widget _buildTestApp() {
    return RepositoryProvider<AppDiContainer>.value(
      value: di,
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  MainCubit _makeMainCubit() {
    final catRepository = _FakeCatRepository();
    final likesRepository = _FakeLikesRepository();
    return MainCubit(
      fetchCatsStream: FetchCatsStreamUseCase(catRepository),
      fetchBreedById: FetchBreedByIdUseCase(catRepository),
      getLikesCount: GetLikesCountUseCase(likesRepository),
      setLikesCount: SetLikesCountUseCase(likesRepository),
      addLikedCat: AddLikedCatUseCase(likesRepository),
    );
  }

  testWidgets('invalid input shows validation errors', (tester) async {
    final authCubit = AuthCubit(
      signInUseCase: SignInUseCase(
        authRepository,
        sessionRepository,
        analyticsRepository,
      ),
      signUpUseCase: SignUpUseCase(
        authRepository,
        sessionRepository,
        analyticsRepository,
      ),
    );

    when(() => di.makeAuthCubit()).thenReturn(authCubit);
    when(() => di.makeMainCubit()).thenReturn(_makeMainCubit());

    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('valid login navigates to main screen', (tester) async {
    when(
      () => authRepository.validateCredentials(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => true);
    when(() => sessionRepository.startSession(any())).thenAnswer((_) async {});

    final authCubit = AuthCubit(
      signInUseCase: SignInUseCase(
        authRepository,
        sessionRepository,
        analyticsRepository,
      ),
      signUpUseCase: SignUpUseCase(
        authRepository,
        sessionRepository,
        analyticsRepository,
      ),
    );

    when(() => di.makeAuthCubit()).thenReturn(authCubit);
    when(() => di.makeMainCubit()).thenReturn(_makeMainCubit());

    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'cat@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secure123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MainScreen), findsOneWidget);
    verify(
      () => authRepository.validateCredentials(
        email: 'cat@example.com',
        password: 'secure123',
      ),
    ).called(1);
    verify(() => sessionRepository.startSession(any())).called(1);
  });
}
