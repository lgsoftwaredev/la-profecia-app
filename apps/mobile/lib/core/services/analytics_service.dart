import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  FirebaseAnalytics? _analytics;

  Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
    } catch (_) {
      _analytics = null;
    }
  }

  Future<void> logAppOpen() => _log('app_open');

  Future<void> logTutorialCompleted() => _log('tutorial_completed');

  Future<void> syncUserContext({
    required bool isAuthenticated,
    required bool isPremium,
    String? userId,
  }) async {
    final analytics = _analytics;
    if (analytics == null) {
      return;
    }
    try {
      await analytics.setUserId(id: isAuthenticated ? userId : null);
      await analytics.setUserProperty(
        name: 'auth_state',
        value: isAuthenticated ? 'authenticated' : 'guest',
      );
      await analytics.setUserProperty(
        name: 'premium_state',
        value: isPremium ? 'premium' : 'free',
      );
      await analytics.setUserProperty(name: 'platform', value: _platformLabel);
    } catch (_) {
      if (kDebugMode) {
        debugPrint('Analytics user context update dropped');
      }
    }
  }

  Future<void> logGameStarted({
    required String mode,
    required int playersCount,
    required String startingLevel,
  }) => _log('game_started', <String, Object>{
    'mode': mode,
    'players_count': playersCount,
    'starting_level': startingLevel,
  });

  Future<void> logRoundCompleted({
    required int round,
    required bool didComplete,
    required String level,
    required String promptType,
  }) => _log('round_completed', <String, Object>{
    'round': round,
    'did_complete': didComplete,
    'level': level,
    'prompt_type': promptType,
  });

  Future<void> logPremiumCtaViewed({
    required String source,
    required bool isGuest,
    String? level,
  }) {
    final params = <String, Object>{
      'source': source,
      'is_guest': isGuest ? 'true' : 'false',
    };
    if (level != null && level.isNotEmpty) {
      params['level'] = level;
    }
    return _log('premium_cta_viewed', params);
  }

  Future<void> logPremiumPurchaseStarted({
    required String productId,
    required String store,
    String? displayPrice,
  }) {
    final params = <String, Object>{'product_id': productId, 'store': store};
    if (displayPrice != null && displayPrice.isNotEmpty) {
      params['display_price'] = displayPrice;
    }
    return _log('premium_purchase_started', params);
  }

  Future<void> logPremiumPurchaseSuccess({
    required String productId,
    required String store,
  }) => _log('premium_purchase_success', <String, Object>{
    'product_id': productId,
    'store': store,
  });

  Future<void> logPremiumPurchaseFailed({
    required String productId,
    required String reason,
    required String store,
  }) => _log('premium_purchase_failed', <String, Object>{
    'product_id': productId,
    'reason': reason,
    'store': store,
  });

  Future<void> logPremiumRestoreStarted({required String store}) =>
      _log('premium_restore_started', <String, Object>{'store': store});

  Future<void> logPremiumRestoreSuccess({required String store}) =>
      _log('premium_restore_success', <String, Object>{'store': store});

  Future<void> logPremiumRestoreFailed({
    required String store,
    required String reason,
  }) => _log('premium_restore_failed', <String, Object>{
    'store': store,
    'reason': reason,
  });

  Future<void> logSuggestionSubmitted({
    required String type,
    required int contentLength,
  }) => _log('suggestion_submitted', <String, Object>{
    'type': type,
    'content_length': contentLength,
  });

  String get _platformLabel {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      default:
        return 'other';
    }
  }

  Future<void> _log(String name, [Map<String, Object>? params]) async {
    final analytics = _analytics;
    if (analytics == null) {
      return;
    }
    try {
      await analytics.logEvent(name: name, parameters: params);
    } catch (_) {
      // Analytics should never break app flow.
      if (kDebugMode) {
        debugPrint('Analytics event dropped: $name');
      }
    }
  }
}
