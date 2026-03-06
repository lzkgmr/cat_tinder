import 'package:cat_tinder/data/auth/firebase_auth_service.dart';
import 'package:cat_tinder/data/analytics/firebase_analytics_service.dart';
import 'package:cat_tinder/data/datasources/local/onboarding_local_data_source.dart';
import 'package:cat_tinder/data/datasources/local/storage_service.dart';
import 'package:cat_tinder/data/datasources/remote/cat_api_service.dart';
import 'package:cat_tinder/data/repositories/firebase_analytics_repository.dart';
import 'package:cat_tinder/data/repositories/api_cat_repository.dart';
import 'package:cat_tinder/data/repositories/firebase_auth_repository.dart';
import 'package:cat_tinder/data/repositories/firebase_session_repository.dart';
import 'package:cat_tinder/data/repositories/local_likes_repository.dart';
import 'package:cat_tinder/data/repositories/local_onboarding_repository.dart';
import 'package:cat_tinder/domain/repositories/auth_repository.dart';
import 'package:cat_tinder/domain/repositories/analytics_repository.dart';
import 'package:cat_tinder/domain/repositories/cat_repository.dart';
import 'package:cat_tinder/domain/repositories/likes_repository.dart';
import 'package:cat_tinder/domain/repositories/onboarding_repository.dart';
import 'package:cat_tinder/domain/repositories/session_repository.dart';
import 'package:cat_tinder/domain/usecases/auth/auth_use_cases.dart';
import 'package:cat_tinder/domain/usecases/cats/cat_use_cases.dart';
import 'package:cat_tinder/domain/usecases/likes/likes_use_cases.dart';
import 'package:cat_tinder/domain/usecases/onboarding/onboarding_use_cases.dart';
import 'package:cat_tinder/presentation/cubit/auth/auth_cubit.dart';
import 'package:cat_tinder/presentation/cubit/breeds/breeds_cubit.dart';
import 'package:cat_tinder/presentation/cubit/liked_cats/liked_cats_cubit.dart';
import 'package:cat_tinder/presentation/cubit/main/main_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDiContainer {
  AppDiContainer._({
    required this.storageService,
    required this.onboardingLocalDataSource,
    required this.catRepository,
    required this.likesRepository,
    required this.authRepository,
    required this.analyticsRepository,
    required this.onboardingRepository,
    required this.sessionRepository,
    required this.fetchCatsStreamUseCase,
    required this.fetchBreedsUseCase,
    required this.fetchBreedByIdUseCase,
    required this.getLikesCountUseCase,
    required this.setLikesCountUseCase,
    required this.getLikedCatsUseCase,
    required this.addLikedCatUseCase,
    required this.removeLikedCatUseCase,
    required this.clearLikedCatsUseCase,
    required this.isOnboardingCompletedUseCase,
    required this.completeOnboardingUseCase,
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.isAuthorizedUseCase,
    required this.getCurrentUserUseCase,
  });

  static Future<AppDiContainer> create() async {
    final prefs = await SharedPreferences.getInstance();

    // Storage/data sources layer
    final storageService = StorageService(prefs);
    final onboardingLocalDataSource = SharedPrefsOnboardingLocalDataSource(
      prefs,
    );
    final catRemoteDataSource = CatApiService(
      apiKey: const String.fromEnvironment('CAT_API_KEY', defaultValue: ''),
    );
    final firebaseAuthService = FirebaseAuthService();
    final firebaseAnalyticsService = FirebaseAnalyticsService();

    // Repositories layer
    final catRepository = ApiCatRepository(remoteDataSource: catRemoteDataSource);
    final likesRepository = LocalLikesRepository(storageService);
    final authRepository = FirebaseAuthRepository(firebaseAuthService);
    final analyticsRepository = FirebaseAnalyticsRepository(
      firebaseAnalyticsService,
    );
    final onboardingRepository = LocalOnboardingRepository(
      onboardingLocalDataSource,
    );
    final sessionRepository = FirebaseSessionRepository(firebaseAuthService);

    // Use cases layer
    final fetchCatsStreamUseCase = FetchCatsStreamUseCase(catRepository);
    final fetchBreedsUseCase = FetchBreedsUseCase(catRepository);
    final fetchBreedByIdUseCase = FetchBreedByIdUseCase(catRepository);
    final getLikesCountUseCase = GetLikesCountUseCase(likesRepository);
    final setLikesCountUseCase = SetLikesCountUseCase(likesRepository);
    final getLikedCatsUseCase = GetLikedCatsUseCase(likesRepository);
    final addLikedCatUseCase = AddLikedCatUseCase(likesRepository);
    final removeLikedCatUseCase = RemoveLikedCatUseCase(likesRepository);
    final clearLikedCatsUseCase = ClearLikedCatsUseCase(likesRepository);
    final isOnboardingCompletedUseCase = IsOnboardingCompletedUseCase(
      onboardingRepository,
    );
    final completeOnboardingUseCase = CompleteOnboardingUseCase(
      onboardingRepository,
    );
    final signInUseCase = SignInUseCase(
      authRepository,
      sessionRepository,
      analyticsRepository,
    );
    final signUpUseCase = SignUpUseCase(
      authRepository,
      sessionRepository,
      analyticsRepository,
    );
    final signOutUseCase = SignOutUseCase(sessionRepository);
    final isAuthorizedUseCase = IsAuthorizedUseCase(sessionRepository);
    final getCurrentUserUseCase = GetCurrentUserUseCase(sessionRepository);

    return AppDiContainer._(
      storageService: storageService,
      onboardingLocalDataSource: onboardingLocalDataSource,
      catRepository: catRepository,
      likesRepository: likesRepository,
      authRepository: authRepository,
      analyticsRepository: analyticsRepository,
      onboardingRepository: onboardingRepository,
      sessionRepository: sessionRepository,
      fetchCatsStreamUseCase: fetchCatsStreamUseCase,
      fetchBreedsUseCase: fetchBreedsUseCase,
      fetchBreedByIdUseCase: fetchBreedByIdUseCase,
      getLikesCountUseCase: getLikesCountUseCase,
      setLikesCountUseCase: setLikesCountUseCase,
      getLikedCatsUseCase: getLikedCatsUseCase,
      addLikedCatUseCase: addLikedCatUseCase,
      removeLikedCatUseCase: removeLikedCatUseCase,
      clearLikedCatsUseCase: clearLikedCatsUseCase,
      isOnboardingCompletedUseCase: isOnboardingCompletedUseCase,
      completeOnboardingUseCase: completeOnboardingUseCase,
      signInUseCase: signInUseCase,
      signUpUseCase: signUpUseCase,
      signOutUseCase: signOutUseCase,
      isAuthorizedUseCase: isAuthorizedUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
    );
  }

  // Storage/data sources
  final StorageService storageService;
  final OnboardingLocalDataSource onboardingLocalDataSource;

  // Repositories
  final CatRepository catRepository;
  final LikesRepository likesRepository;
  final AuthRepository authRepository;
  final AnalyticsRepository analyticsRepository;
  final OnboardingRepository onboardingRepository;
  final SessionRepository sessionRepository;

  // Use cases
  final FetchCatsStreamUseCase fetchCatsStreamUseCase;
  final FetchBreedsUseCase fetchBreedsUseCase;
  final FetchBreedByIdUseCase fetchBreedByIdUseCase;
  final GetLikesCountUseCase getLikesCountUseCase;
  final SetLikesCountUseCase setLikesCountUseCase;
  final GetLikedCatsUseCase getLikedCatsUseCase;
  final AddLikedCatUseCase addLikedCatUseCase;
  final RemoveLikedCatUseCase removeLikedCatUseCase;
  final ClearLikedCatsUseCase clearLikedCatsUseCase;
  final IsOnboardingCompletedUseCase isOnboardingCompletedUseCase;
  final CompleteOnboardingUseCase completeOnboardingUseCase;
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final IsAuthorizedUseCase isAuthorizedUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  // Presentation controllers
  MainCubit makeMainCubit() {
    return MainCubit(
      fetchCatsStream: fetchCatsStreamUseCase,
      fetchBreedById: fetchBreedByIdUseCase,
      getLikesCount: getLikesCountUseCase,
      setLikesCount: setLikesCountUseCase,
      addLikedCat: addLikedCatUseCase,
    );
  }

  BreedsCubit makeBreedsCubit() {
    return BreedsCubit(fetchBreeds: fetchBreedsUseCase);
  }

  LikedCatsCubit makeLikedCatsCubit() {
    return LikedCatsCubit(
      getLikedCats: getLikedCatsUseCase,
      removeLikedCat: removeLikedCatUseCase,
      clearLikedCats: clearLikedCatsUseCase,
    );
  }

  AuthCubit makeAuthCubit() {
    return AuthCubit(signInUseCase: signInUseCase, signUpUseCase: signUpUseCase);
  }
}
