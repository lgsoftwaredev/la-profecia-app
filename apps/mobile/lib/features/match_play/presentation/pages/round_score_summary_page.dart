import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/services/ad_service.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../../../player_setup/presentation/pages/start_points_page.dart';
import 'final_judgment_page.dart';
import 'round_score_summary_couple_page.dart';
import 'round_score_summary_friends_page.dart';

class RoundScoreSummaryPage extends ConsumerWidget {
  const RoundScoreSummaryPage({
    required this.submission,
    required this.completedPlayerId,
    required this.scoresByPlayerId,
    this.round = 1,
    this.gainedPoints = 10,
    this.didComplete = true,
    this.endMatchOnNext = false,
    super.key,
  });

  final GameSetupSubmission submission;
  final int completedPlayerId;
  final Map<int, int> scoresByPlayerId;
  final int round;
  final int gainedPoints;
  final bool didComplete;
  final bool endMatchOnNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onNextRoundTap() async {
      await ref
          .read(adServiceProvider)
          .showInterstitialIfEligible(AdPlacement.roundSummaryToNextRound);
      if (!context.mounted) {
        return;
      }
      if (endMatchOnNext) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FinalJudgmentPage(
              submission: submission,
              scoresByPlayerId: scoresByPlayerId,
            ),
          ),
        );
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => StartPointsPage(submission: submission),
        ),
      );
    }

    if (submission.mode.isFriends) {
      return RoundScoreSummaryFriendsPage(
        submission: submission,
        completedPlayerId: completedPlayerId,
        scoresByPlayerId: scoresByPlayerId,
        round: round,
        gainedPoints: gainedPoints,
        didComplete: didComplete,
        endMatchOnNext: endMatchOnNext,
        onNextRoundTap: onNextRoundTap,
      );
    }

    return RoundScoreSummaryCouplePage(
      submission: submission,
      completedPlayerId: completedPlayerId,
      scoresByPlayerId: scoresByPlayerId,
      round: round,
      gainedPoints: gainedPoints,
      didComplete: didComplete,
      endMatchOnNext: endMatchOnNext,
      onNextRoundTap: onNextRoundTap,
    );
  }
}
