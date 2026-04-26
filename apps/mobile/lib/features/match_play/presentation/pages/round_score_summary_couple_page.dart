import 'package:flutter/material.dart';

import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../widgets/round_score_summary_mode_page.dart';

class RoundScoreSummaryCouplePage extends StatelessWidget {
  const RoundScoreSummaryCouplePage({
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
      backgroundAsset: 'assets/background-setup-couple-mode.png',
      modeAccent: const Color(0xFFE94494),
      buttonGradient: const [Color(0xFFF574B9), Color(0xFFD93D88)],
      baseNumberCircle: const Color(0xFFE94494),
      usePremiumPairCards: true,
      pairTotalChipHeight: 62,
      pairCardTopHighlightOpacity: 0.08,
      pairCardBottomShadeOpacity: 0.16,
      pairCardInnerBorderAlpha: 0.04,
      onNextRoundTap: onNextRoundTap,
      onFinishMatchTap: onFinishMatchTap,
    );
  }
}
