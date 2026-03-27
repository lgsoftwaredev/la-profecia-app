import 'package:flutter/material.dart';

import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../widgets/final_prophecy_challenge_mode_page.dart';

class FinalProphecyChallengePage extends StatelessWidget {
  const FinalProphecyChallengePage({
    required this.submission,
    required this.punishedLabel,
    this.challengeText = 'Besa al Ganador en la boca...',
    this.onPlayAgainTap,
    this.onBackToHomeTap,
    super.key,
  });

  final GameSetupSubmission submission;
  final String punishedLabel;
  final String challengeText;
  final VoidCallback? onPlayAgainTap;
  final VoidCallback? onBackToHomeTap;

  @override
  Widget build(BuildContext context) {
    return FinalProphecyChallengeModePage(
      submission: submission,
      punishedLabel: punishedLabel,
      challengeText: challengeText,
      onPlayAgainTap: onPlayAgainTap,
      onBackToHomeTap: onBackToHomeTap,
    );
  }
}
