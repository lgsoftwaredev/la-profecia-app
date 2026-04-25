import '../entities/auth_session.dart';

abstract class AuthRepository {
  Stream<AuthSession?> watchSession();
  Future<AuthSession?> restoreSession();

  Future<AuthSession> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String phone,
  });

  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthSession> signInWithGoogle();
  Future<AuthSession> signInWithApple();
  Future<void> sendPasswordResetCode({required String email});
  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  });
  Future<void> signOut();
}
