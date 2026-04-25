import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/supabase_auth_datasource.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._dataSource);

  final SupabaseAuthDataSource _dataSource;

  @override
  Stream<AuthSession?> watchSession() => _dataSource.watchSession();

  @override
  Future<AuthSession?> restoreSession() => _dataSource.restoreSession();

  @override
  Future<AuthSession> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String phone,
  }) {
    return _dataSource.signUpWithEmail(
      email: email,
      password: password,
      username: username,
      phone: phone,
    );
  }

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _dataSource.signInWithEmail(email: email, password: password);
  }

  @override
  Future<AuthSession> signInWithGoogle() => _dataSource.signInWithGoogle();

  @override
  Future<AuthSession> signInWithApple() => _dataSource.signInWithApple();

  @override
  Future<void> sendPasswordResetCode({required String email}) {
    return _dataSource.sendPasswordResetCode(email: email);
  }

  @override
  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _dataSource.resetPasswordWithCode(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> signOut() => _dataSource.signOut();
}
