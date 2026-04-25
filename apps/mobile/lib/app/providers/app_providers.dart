import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/ad_service.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/push_notification_service.dart';
import '../di/app_scope.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/match_play/presentation/controllers/match_controller.dart';
import '../../features/premium/domain/services/entitlement_service.dart';
import '../../features/premium/domain/services/purchase_service.dart';
import '../../features/profile/domain/services/profile_service.dart';
import '../../features/suggestions/domain/services/suggestions_service.dart';

final appScopeProvider = Provider<AppScope>((ref) {
  throw StateError('AppScope no fue inicializado.');
});

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return ref.watch(appScopeProvider).authController;
});

final matchControllerProvider = ChangeNotifierProvider<MatchController>((ref) {
  return ref.watch(appScopeProvider).matchController;
});

final entitlementServiceProvider = Provider<EntitlementService>((ref) {
  return ref.watch(appScopeProvider).entitlementService;
});

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return ref.watch(appScopeProvider).purchaseService;
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return ref.watch(appScopeProvider).analyticsService;
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  return ref.watch(appScopeProvider).pushNotificationService;
});

final adServiceProvider = Provider<AdService>((ref) {
  return ref.watch(appScopeProvider).adService;
});

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ref.watch(appScopeProvider).profileService;
});

final suggestionsServiceProvider = Provider<SuggestionsService>((ref) {
  return ref.watch(appScopeProvider).suggestionsService;
});
