import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/app_scope.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/match_play/presentation/controllers/match_controller.dart';
import '../../features/premium/domain/services/entitlement_service.dart';

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
