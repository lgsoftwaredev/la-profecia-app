import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_environment.dart';

class PushNotificationService {
  PushNotificationService({
    required SharedPreferences preferences,
    required SupabaseClient? client,
  }) : _preferences = preferences,
       _client = client;

  final SharedPreferences _preferences;
  final SupabaseClient? _client;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const _installationIdKey = 'push_installation_id';
  static const _lastFcmTokenKey = 'push_last_fcm_token';
  static const _notificationsEnabledKey = 'push_notifications_enabled';

  bool _initialized = false;
  String? _lastToken;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  Future<void> initialize({required String? currentUserId}) async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _lastToken = _preferences.getString(_lastFcmTokenKey);

    if (AppEnvironment.enablePushAutoPermissionPrompt) {
      await requestPermissions();
    }

    _foregroundSubscription = FirebaseMessaging.onMessage.listen((_) {});
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) async {
      await _persistToken(
        token: token,
        currentUserId: currentUserId,
        notificationsEnabled: _preferences.getBool(_notificationsEnabledKey),
      );
    });

    await _tryFetchInitialToken(currentUserId: currentUserId, attempt: 0);
  }

  Future<void> requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    final enabled =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    await _preferences.setBool(_notificationsEnabledKey, enabled);
  }

  Future<void> syncForCurrentUser(String? userId) async {
    if (!_initialized) {
      return;
    }
    final token = _lastToken;
    if (token == null || token.isEmpty) {
      return;
    }
    await _upsertTokenRow(
      token: token,
      currentUserId: userId,
      notificationsEnabled: _preferences.getBool(_notificationsEnabledKey),
    );
  }

  Future<void> _persistToken({
    required String token,
    required String? currentUserId,
    required bool? notificationsEnabled,
  }) async {
    _lastToken = token;
    await _preferences.setString(_lastFcmTokenKey, token);
    await _upsertTokenRow(
      token: token,
      currentUserId: currentUserId,
      notificationsEnabled: notificationsEnabled,
    );
  }

  Future<void> _tryFetchInitialToken({
    required String? currentUserId,
    required int attempt,
  }) async {
    const maxAttempts = 6;
    if (attempt >= maxAttempts) {
      return;
    }

    if (Platform.isIOS) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null || apnsToken.isEmpty) {
        unawaited(
          Future<void>.delayed(const Duration(seconds: 2), () async {
            await _tryFetchInitialToken(
              currentUserId: currentUserId,
              attempt: attempt + 1,
            );
          }),
        );
        return;
      }
    }

    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        return;
      }
      await _persistToken(
        token: token,
        currentUserId: currentUserId,
        notificationsEnabled: _preferences.getBool(_notificationsEnabledKey),
      );
    } catch (error) {
      final message = error.toString();
      if (message.contains('apns-token-not-set')) {
        unawaited(
          Future<void>.delayed(const Duration(seconds: 2), () async {
            await _tryFetchInitialToken(
              currentUserId: currentUserId,
              attempt: attempt + 1,
            );
          }),
        );
        return;
      }
      // Keep startup resilient if token retrieval fails.
    }
  }

  Future<void> _upsertTokenRow({
    required String token,
    required String? currentUserId,
    required bool? notificationsEnabled,
  }) async {
    final client = _client;
    if (client == null) {
      return;
    }
    final installationId = _getOrCreateInstallationId();
    try {
      await client.from('PushDeviceToken').upsert(<String, dynamic>{
        'installationId': installationId,
        'fcmToken': token,
        'platform': _resolvePlatform(),
        'userId': currentUserId,
        'notificationsEnabled': notificationsEnabled ?? false,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'installationId');
    } catch (_) {
      // Keep push initialization resilient when backend policies are not deployed yet.
    }
  }

  String _getOrCreateInstallationId() {
    final cached = _preferences.getString(_installationIdKey);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    final random = Random();
    final id =
        'inst-${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(999999).toString().padLeft(6, '0')}';
    unawaited(_preferences.setString(_installationIdKey, id));
    return id;
  }

  String _resolvePlatform() {
    if (Platform.isAndroid) {
      return 'ANDROID';
    }
    if (Platform.isIOS) {
      return 'IOS';
    }
    return 'OTHER';
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
  }
}
