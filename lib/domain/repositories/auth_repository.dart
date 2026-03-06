abstract class AuthRepository {
  Future<void> register({required String email, required String password});

  Future<bool> validateCredentials({
    required String email,
    required String password,
  });

  Future<bool> hasAccount(String email);
}
