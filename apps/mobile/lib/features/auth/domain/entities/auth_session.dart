import '../value_objects/auth_provider_type.dart';

class AuthSession {
  const AuthSession({
    required this.userId,
    required this.provider,
    this.email,
    this.username,
    this.displayName,
    this.accessToken,
  });

  final String userId;
  final AuthProviderType provider;
  final String? email;
  final String? username;
  final String? displayName;
  final String? accessToken;

  bool get isAuthenticated => provider != AuthProviderType.guest;
}
