import 'package:flutter/material.dart';

import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../widgets/round_score_summary_mode_page.dart';

class RoundScoreSummaryFriendsPage extends StatelessWidget {
  const RoundScoreSummaryFriendsPage({
    required this.submission,
    required this.completedPlayerId,
    required this.scoresByPlayerId,
    this.round = 1,
    this.gainedPoints = 10,
    this.didComplete = true,
    this.endMatchOnNext = false,
    required this.onNextRoundTap,
    required this.onFinishMatchTap,
    super.key,
  });

  final GameSetupSubmission submission;
  final int completedPlayerId;
  final Map<int, int> scoresByPlayerId;
  final int round;
  final int gainedPoints;
  final bool didComplete;
  final bool endMatchOnNext;
  final VoidCallback onNextRoundTap;
  final VoidCallback onFinishMatchTap;

  @override
  Widget build(BuildContext context) {
    return RoundScoreSummaryModePage(
      submission: submission,
      completedPlayerId: completedPlayerId,
      scoresByPlayerId: scoresByPlayerId,
      round: round,
      gainedPoints: gainedPoints,
      didComplete: didComplete,
      backgroundAsset: 'assets/background-setup-friends-mode.png',
      modeAccent: const Color(0xFF0787FF),
      buttonGradient: const [Color(0xFF5FC0FF), Color(0xFF2E6FC9)],
      baseNumberCircle: const Color(0xFF1BA8FF),
      usePremiumPairCards: false,
      pairTotalChipHeight: 42,
      onNextRoundTap: onNextRoundTap,
      onFinishMatchTap: onFinishMatchTap,
    );
  }
}
