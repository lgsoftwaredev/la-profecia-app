class AuthSessionStore {
  AuthSessionStore._();

  static bool hasSession = false;

  static void signIn() {
    hasSession = true;
  }

  static void signOut() {
    hasSession = false;
  }
}
