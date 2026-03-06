import 'package:cat_tinder/data/auth/firebase_auth_service.dart';
import 'package:cat_tinder/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuthService _service;

  FirebaseAuthRepository(this._service);

  @override
  Future<void> register({required String email, required String password}) async {
    try {
      await _service.signUp(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw StateError(_mapFirebaseError(e));
    } catch (_) {
      throw StateError('Storage error. Please try again.');
    }
  }

  @override
  Future<bool> validateCredentials({
    required String email,
    required String password,
  }) async {
    try {
      await _service.signIn(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' ||
          e.code == 'user-not-found' ||
          e.code == 'invalid-email' ||
          e.code == 'invalid-credential') {
        return false;
      }
      throw StateError(_mapFirebaseError(e));
    } catch (_) {
      throw StateError('Storage error. Please try again.');
    }
  }

  @override
  Future<bool> hasAccount(String email) async {
    // Firebase Auth no longer supports safe account discovery via email
    // in recent SDK versions. This method is kept only for interface compatibility.
    return true;
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      default:
        return e.message ?? 'Auth error. Please try again.';
    }
  }
}
