import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../domain/entities/auth_session.dart';
import '../controllers/auth_controller.dart';

final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(
    authControllerProvider.select((controller) {
      return controller.status;
    }),
  );
});

final authSessionProvider = Provider<AuthSession?>((ref) {
  return ref.watch(
    authControllerProvider.select((controller) {
      return controller.session;
    }),
  );
});

final authErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(
    authControllerProvider.select((controller) {
      return controller.errorMessage;
    }),
  );
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(
    authControllerProvider.select((controller) {
      return controller.isAuthenticated;
    }),
  );
});

final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(
    authControllerProvider.select((controller) {
      return controller.isLoading;
    }),
  );
});
