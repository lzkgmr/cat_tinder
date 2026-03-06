class AuthValidationResult {
  final String? emailError;
  final String? passwordError;

  const AuthValidationResult({this.emailError, this.passwordError});

  bool get isValid => emailError == null && passwordError == null;
}

class ValidateAuthInputUseCase {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  AuthValidationResult call({
    required String email,
    required String password,
  }) {
    final trimmedEmail = email.trim();

    String? emailError;
    if (trimmedEmail.isEmpty) {
      emailError = 'Email is required';
    } else if (!_emailRegex.hasMatch(trimmedEmail)) {
      emailError = 'Invalid email format';
    }

    String? passwordError;
    if (password.isEmpty) {
      passwordError = 'Password is required';
    } else if (password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
    }

    return AuthValidationResult(
      emailError: emailError,
      passwordError: passwordError,
    );
  }
}
