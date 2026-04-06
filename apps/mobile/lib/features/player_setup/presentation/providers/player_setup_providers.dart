import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/auth_session.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../controllers/player_setup_controller.dart';

class PlayerSetupParams {
  const PlayerSetupParams({required this.mode, required this.isPremium});

  final GameMode mode;
  final bool isPremium;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is PlayerSetupParams &&
        other.mode == mode &&
        other.isPremium == isPremium;
  }

  @override
  int get hashCode => Object.hash(mode, isPremium);
}

final playerSetupControllerProvider = ChangeNotifierProvider.autoDispose
    .family<PlayerSetupController, PlayerSetupParams>((ref, params) {
      final authSession = ref.watch(authSessionProvider);
      final authenticatedUserId = authSession?.isAuthenticated == true
          ? authSession!.userId
          : null;
      final controller = PlayerSetupController(
        mode: params.mode,
        isPremium: params.isPremium,
        authenticatedUserId: authenticatedUserId,
        authenticatedPlayerName: _resolveAuthenticatedPlayerName(authSession),
      );
      ref.onDispose(controller.dispose);
      return controller;
    });

String? _resolveAuthenticatedPlayerName(AuthSession? session) {
  if (session == null || !session.isAuthenticated) {
    return null;
  }

  final displayName = session.displayName?.trim();
  if (displayName != null && displayName.isNotEmpty) {
    return displayName;
  }

  final username = session.username?.trim();
  if (username != null && username.isNotEmpty) {
    return username;
  }

  final email = session.email?.trim();
  if (email != null && email.isNotEmpty) {
    final localPart = email.split('@').first.trim();
    if (localPart.isNotEmpty) {
      return localPart;
    }
  }

  return null;
}
