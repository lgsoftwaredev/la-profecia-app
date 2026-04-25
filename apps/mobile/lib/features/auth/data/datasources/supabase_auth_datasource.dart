import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/value_objects/auth_provider_type.dart';

class SupabaseAuthDataSource {
  SupabaseAuthDataSource({
    required SupabaseClient? client,
    String? googleServerClientId,
    String? googleIosClientId,
  }) : _client = client,
       _googleServerClientId = (googleServerClientId ?? '').trim(),
       _googleIosClientId = (googleIosClientId ?? '').trim(),
       _googleSignIn = GoogleSignIn(
         serverClientId: _normalizedClientId(googleServerClientId),
         clientId: (Platform.isIOS || Platform.isMacOS)
             ? _normalizedClientId(googleIosClientId)
             : null,
       );

  final SupabaseClient? _client;
  final String _googleServerClientId;
  final String _googleIosClientId;
  final GoogleSignIn _googleSignIn;

  Stream<AuthSession?> watchSession() {
    final client = _client;
    if (client == null) {
      return Stream<AuthSession?>.value(null);
    }

    return client.auth.onAuthStateChange.map((authState) {
      final session = authState.session;
      if (session == null) {
        return null;
      }
      Future<void>(() => _ensureProfileForUser(session.user));
      return _toAuthSession(
        session.user,
        accessToken: session.accessToken,
        providerHint: session.user.appMetadata['provider'] as String?,
      );
    });
  }

  Future<AuthSession?> restoreSession() async {
    final client = _client;
    if (client == null) {
      return null;
    }

    final session = client.auth.currentSession;
    if (session == null) {
      return null;
    }

    await _ensureProfileForUser(session.user);
    return _toAuthSession(
      session.user,
      accessToken: session.accessToken,
      providerHint: session.user.appMetadata['provider'] as String?,
    );
  }

  Future<AuthSession> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String phone,
  }) async {
    final client = _requiredClient();
    final normalizedUsername = username.trim();
    final normalizedPhone = phone.trim();
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: <String, dynamic>{
        'username': normalizedUsername,
        'full_name': normalizedUsername,
        'phone': normalizedPhone,
      },
    );
    final user = response.user;
    if (user == null) {
      throw const AppFailure(
        'No se pudo crear la cuenta. Verifica configuración de confirmación de correo.',
      );
    }

    await _ensureProfileForUser(
      user,
      fallbackUsername: normalizedUsername,
      fallbackPhone: normalizedPhone,
    );
    return _toAuthSession(
      user,
      accessToken: response.session?.accessToken,
      providerHint: 'email',
    );
  }

  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final client = _requiredClient();
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AppFailure('No se pudo iniciar sesion con email.');
    }

    await _ensureProfileForUser(user);
    return _toAuthSession(
      user,
      accessToken: response.session?.accessToken,
      providerHint: 'email',
    );
  }

  Future<void> sendPasswordResetCode({required String email}) async {
    final client = _requiredClient();
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      throw const AppFailure('Ingresa un correo valido.');
    }

    try {
      await client.auth.resetPasswordForEmail(normalizedEmail);
    } on AuthException catch (error) {
      final message = error.message.toLowerCase();
      if (message.contains('email')) {
        throw const AppFailure('Ingresa un correo valido.');
      }
      throw const AppFailure(
        'No se pudo enviar el codigo de recuperación. Intenta nuevamente.',
      );
    } catch (_) {
      throw const AppFailure(
        'No se pudo enviar el codigo de recuperación. Intenta nuevamente.',
      );
    }
  }

  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final client = _requiredClient();
    final normalizedEmail = email.trim();
    final normalizedCode = code.trim();
    final normalizedPassword = newPassword.trim();
    if (normalizedEmail.isEmpty) {
      throw const AppFailure('Ingresa un correo valido.');
    }
    if (normalizedCode.isEmpty) {
      throw const AppFailure('Ingresa el codigo de recuperación.');
    }
    if (normalizedPassword.length < 6) {
      throw const AppFailure('La contraseña debe tener al menos 6 caracteres.');
    }

    try {
      await client.auth.verifyOTP(
        email: normalizedEmail,
        token: normalizedCode,
        type: OtpType.recovery,
      );
      await client.auth.updateUser(
        UserAttributes(password: normalizedPassword),
      );
      await client.auth.signOut();
    } on AuthException catch (error) {
      final code = (error.code ?? '').toLowerCase();
      final message = error.message.toLowerCase();
      if (code == 'same_password' ||
          message.contains(
            'new password should be different from the old password.',
          )) {
        throw const AppFailure(
          'La nueva contraseña debe ser diferente a la anterior.',
        );
      }
      if (message.contains('token') ||
          message.contains('otp') ||
          message.contains('expired') ||
          message.contains('invalid')) {
        throw const AppFailure('El codigo es invalido o expiró.');
      }
      if (message.contains('password')) {
        throw const AppFailure(
          'No se pudo actualizar la contraseña. Verifica los requisitos.',
        );
      }
      throw const AppFailure(
        'No se pudo restablecer la contraseña. Intenta nuevamente.',
      );
    } catch (_) {
      throw const AppFailure(
        'No se pudo restablecer la contraseña. Intenta nuevamente.',
      );
    }
  }

  Future<AuthSession> signInWithGoogle() async {
    final client = _requiredClient();
    _validateGoogleSignInConfig();

    GoogleSignInAccount? googleUser;
    try {
      googleUser = await _googleSignIn.signIn().timeout(
        const Duration(seconds: 20),
      );
    } on TimeoutException {
      throw const AppFailure(
        'Google tardó demasiado en responder. Verifica configuración OAuth y conexión.',
      );
    } catch (error) {
      throw AppFailure(_googleSignInErrorMessage(error));
    }

    if (googleUser == null) {
      throw const AppFailure('Inicio de sesion con Google cancelado.');
    }

    final googleAuth = await googleUser.authentication.timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        throw const AppFailure(
          'Google no respondió con credenciales a tiempo.',
        );
      },
    );
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw const AppFailure('Google no devolvio idToken.');
    }

    final response = await client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    final user = response.user;
    if (user == null) {
      throw const AppFailure('No se pudo completar login con Google.');
    }

    await _ensureProfileForUser(user);
    return _toAuthSession(
      user,
      accessToken: response.session?.accessToken,
      providerHint: 'google',
    );
  }

  static String? _normalizedClientId(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  void _validateGoogleSignInConfig() {
    if (_googleServerClientId.isEmpty) {
      throw const AppFailure(
        'Falta GOOGLE_SERVER_CLIENT_ID. Configura el client web de Google.',
      );
    }
    if ((Platform.isIOS || Platform.isMacOS) && _googleIosClientId.isEmpty) {
      throw const AppFailure(
        'Falta GOOGLE_IOS_CLIENT_ID para iniciar sesión con Google en iOS.',
      );
    }
  }

  String _googleSignInErrorMessage(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('canceled') || message.contains('cancelled')) {
      return 'Inicio de sesion con Google cancelado.';
    }
    if (message.contains('network')) {
      return 'No se pudo conectar con Google. Verifica tu conexión.';
    }
    if (message.contains('10') ||
        message.contains('developer_error') ||
        message.contains('oauth')) {
      return 'Error OAuth de Google. Revisa package/bundle, SHA y client IDs.';
    }
    return 'No se pudo iniciar sesión con Google. Revisa configuración OAuth.';
  }

  Future<AuthSession> signInWithApple() async {
    final client = _requiredClient();
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw const AppFailure(
        'Apple Sign-In solo esta disponible en iOS o macOS.',
      );
    }

    final rawNonce = client.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: const <AppleIDAuthorizationScopes>[
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      ).timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const AppFailure(
        'Apple tardó demasiado en responder. Verifica red y configuración.',
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      throw AppFailure(_appleSignInErrorMessage(error));
    } catch (_) {
      throw const AppFailure(
        'No se pudo iniciar sesión con Apple. Revisa tu configuración.',
      );
    }

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AppFailure('Apple no devolvio token de identidad.');
    }

    final response = await client.auth
        .signInWithIdToken(
          provider: OAuthProvider.apple,
          idToken: idToken,
          nonce: rawNonce,
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            throw const AppFailure(
              'Supabase tardó demasiado en validar el token de Apple.',
            );
          },
        );

    final user = response.user;
    if (user == null) {
      throw const AppFailure('No se pudo completar login con Apple.');
    }

    final fullName = _appleFullName(credential);
    await _persistAppleNameMetadata(
      client: client,
      givenName: credential.givenName,
      familyName: credential.familyName,
      fullName: fullName,
    );
    await _ensureProfileForUser(user, fallbackDisplayName: fullName);
    return _toAuthSession(
      user,
      accessToken: response.session?.accessToken,
      providerHint: 'apple',
    );
  }

  String _appleSignInErrorMessage(SignInWithAppleAuthorizationException error) {
    final code = error.code.toString().toLowerCase();
    if (code.contains('canceled') || code.contains('cancelled')) {
      return 'Inicio de sesion con Apple cancelado.';
    }
    if (code.contains('invalidresponse')) {
      return 'Apple devolvio una respuesta invalida.';
    }
    if (code.contains('nothandled') || code.contains('failed')) {
      return 'Apple Sign-In no pudo completarse. Revisa capability y proveedor.';
    }
    if (code.contains('notinteractive')) {
      return 'Apple Sign-In requiere una interacción del usuario.';
    }
    return 'No se pudo iniciar sesión con Apple.';
  }

  String? _appleFullName(AuthorizationCredentialAppleID credential) {
    final pieces = <String>[
      credential.givenName?.trim() ?? '',
      credential.familyName?.trim() ?? '',
    ].where((item) => item.isNotEmpty).toList(growable: false);
    if (pieces.isEmpty) {
      return null;
    }
    return pieces.join(' ');
  }

  Future<void> _persistAppleNameMetadata({
    required SupabaseClient client,
    required String? givenName,
    required String? familyName,
    required String? fullName,
  }) async {
    if ((givenName ?? '').trim().isEmpty &&
        (familyName ?? '').trim().isEmpty &&
        (fullName ?? '').trim().isEmpty) {
      return;
    }

    final metadata = <String, dynamic>{};
    final normalizedGivenName = givenName?.trim();
    final normalizedFamilyName = familyName?.trim();
    final normalizedFullName = fullName?.trim();
    if (normalizedGivenName != null && normalizedGivenName.isNotEmpty) {
      metadata['given_name'] = normalizedGivenName;
    }
    if (normalizedFamilyName != null && normalizedFamilyName.isNotEmpty) {
      metadata['family_name'] = normalizedFamilyName;
    }
    if (normalizedFullName != null && normalizedFullName.isNotEmpty) {
      metadata['full_name'] = normalizedFullName;
      metadata['name'] = normalizedFullName;
    }
    if (metadata.isEmpty) {
      return;
    }

    try {
      await client.auth.updateUser(UserAttributes(data: metadata));
    } catch (_) {
      // Keep login flow successful if metadata update fails.
    }
  }

  Future<void> signOut() async {
    final client = _requiredClient();
    await _googleSignIn.signOut();
    await client.auth.signOut();
  }

  SupabaseClient _requiredClient() {
    final client = _client;
    if (client == null) {
      throw const AppFailure('Servicio de autenticación no disponible.');
    }
    return client;
  }

  AuthSession _toAuthSession(
    User user, {
    String? accessToken,
    String? providerHint,
  }) {
    final provider = switch (providerHint ?? user.appMetadata['provider']) {
      'google' => AuthProviderType.google,
      'apple' => AuthProviderType.apple,
      _ => AuthProviderType.email,
    };

    final displayName =
        user.userMetadata?['full_name'] as String? ??
        user.userMetadata?['name'] as String?;
    final username = user.userMetadata?['username'] as String?;

    return AuthSession(
      userId: user.id,
      provider: provider,
      email: user.email,
      username: username,
      displayName: displayName,
      accessToken: accessToken,
    );
  }

  Future<void> _ensureProfileForUser(
    User user, {
    String? fallbackUsername,
    String? fallbackPhone,
    String? fallbackDisplayName,
  }) async {
    final client = _client;
    if (client == null) {
      return;
    }
    final authenticatedUser = client.auth.currentUser;
    if (authenticatedUser == null) {
      return;
    }
    // RLS evalúa auth.uid() contra el JWT activo, por eso siempre usamos
    // el usuario actual de sesión para id/email del upsert.
    final targetUserId = authenticatedUser.id;
    final targetEmail = authenticatedUser.email ?? user.email;

    final metadata = user.userMetadata;
    final username =
        (metadata?['username'] as String?) ?? fallbackUsername?.trim();
    final displayName =
        (metadata?['full_name'] as String?) ??
        (metadata?['name'] as String?) ??
        fallbackDisplayName?.trim() ??
        username;
    final phone = (metadata?['phone'] as String?) ?? fallbackPhone?.trim();
    final countryCode = _resolveCountryCode(phone);

    try {
      await client.from('Profile').upsert(<String, dynamic>{
        'id': targetUserId,
        'email': targetEmail,
        'username': username,
        'displayName': displayName,
        'countryCode': countryCode,
        'isGuest': false,
      }, onConflict: 'id');

      await client.from('UserStats').upsert(<String, dynamic>{
        'userId': targetUserId,
      }, onConflict: 'userId');

      await client.from('UserPreference').upsert(<String, dynamic>{
        'userId': targetUserId,
      }, onConflict: 'userId');
    } catch (error) {
      if (error is PostgrestException &&
          (error.code ?? '').toLowerCase() == '42501') {
        throw const AppFailure(
          'Permisos insuficientes por RLS en Profile. Revisa que el JWT activo corresponda al mismo id.',
        );
      }
      throw const AppFailure(
        'No se pudo asegurar perfil de usuario. Verifica integridad de datos y permisos.',
      );
    }
  }

  String? _resolveCountryCode(String? phone) {
    final value = phone?.trim() ?? '';
    if (value.startsWith('+57')) {
      return 'CO';
    }
    return null;
  }
}
