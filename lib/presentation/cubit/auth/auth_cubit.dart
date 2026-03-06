import 'package:cat_tinder/domain/usecases/auth/auth_use_cases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;

  AuthCubit({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
  }) : _signInUseCase = signInUseCase,
       _signUpUseCase = signUpUseCase,
       super(AuthState.initial());

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _signInUseCase(email: email, password: password);
      emit(state.copyWith(status: AuthStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: _messageFrom(e)),
      );
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _signUpUseCase(email: email, password: password);
      emit(state.copyWith(status: AuthStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: _messageFrom(e)),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true, status: AuthStatus.initial));
  }

  String _messageFrom(Object error) {
    if (error is StateError) {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }
}
