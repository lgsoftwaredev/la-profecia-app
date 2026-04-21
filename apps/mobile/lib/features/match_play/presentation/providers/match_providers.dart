import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../../domain/entities/match_level.dart';
import '../../domain/entities/match_result.dart';
import '../../domain/entities/match_session.dart';
import '../../domain/entities/match_turn.dart';
import '../../../profile/domain/entities/user_stats_summary.dart';

final matchSessionProvider = Provider<MatchSession?>((ref) {
  return ref.watch(
    matchControllerProvider.select((controller) {
      return controller.session;
    }),
  );
});

final matchFinalResultProvider = Provider<MatchFinalResult?>((ref) {
  return ref.watch(
    matchControllerProvider.select((controller) {
      return controller.finalResult;
    }),
  );
});

final matchLoadingProvider = Provider<bool>((ref) {
  return ref.watch(
    matchControllerProvider.select((controller) {
      return controller.isLoading;
    }),
  );
});

final matchErrorProvider = Provider<String?>((ref) {
  return ref.watch(
    matchControllerProvider.select((controller) {
      return controller.error;
    }),
  );
});

final hasActiveMatchProvider = Provider<bool>((ref) {
  return ref.watch(
    matchControllerProvider.select((controller) {
      return controller.hasActiveMatch;
    }),
  );
});

final matchCurrentTurnProvider = Provider<MatchTurn?>((ref) {
  return ref.watch(
    matchControllerProvider.select((controller) {
      return controller.currentTurn;
    }),
  );
});

final matchScoresProvider = Provider<Map<int, int>>((ref) {
  return ref.watch(
    matchControllerProvider.select((controller) {
      return controller.scoresByPlayerId;
    }),
  );
});

final matchPendingLevelProvider = Provider<MatchLevel?>((ref) {
  return ref.watch(
    matchControllerProvider.select((controller) {
      return controller.pendingLevel;
    }),
  );
});

final matchAvailableLevelsProvider = Provider<List<MatchLevel>>((ref) {
  return ref.watch(
    matchControllerProvider.select((controller) {
      return controller.availableLevels;
    }),
  );
});

final activeSetupSubmissionProvider = StateProvider<GameSetupSubmission?>((
  ref,
) {
  return null;
});

final matchStatsSummaryProvider = FutureProvider<UserStatsSummary>((ref) async {
  final currentUserId = ref.watch(
    authSessionProvider.select((session) {
      return session?.userId;
    }),
  );

  if (currentUserId == null) {
    return const UserStatsSummary(
      matchesPlayed: 0,
      accumulatedScore: 0,
      wins: 0,
      losses: 0,
      history: <GameHistoryItem>[],
    );
  }

  return ref.read(matchControllerProvider).readSummary();
});
