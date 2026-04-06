import '../../../../app/di/app_scope.dart';

class AuthSessionStore {
  AuthSessionStore._();

  static bool get hasSession => AppScope.I.authController.isAuthenticated;

  static void signIn() {}

  static Future<void> signOut() => AppScope.I.authController.signOut();
}
