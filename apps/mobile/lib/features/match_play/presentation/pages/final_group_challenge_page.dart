import 'package:flutter/material.dart';

import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../widgets/final_group_challenge_mode_page.dart';

class FinalGroupChallengePage extends StatelessWidget {
  const FinalGroupChallengePage({
    required this.submission,
    required this.punishedLabel,
    this.onSendTap,
    this.onPlayAgainTap,
    this.onBackToHomeTap,
    super.key,
  });

  final GameSetupSubmission submission;
  final String punishedLabel;
  final Future<bool> Function(String)? onSendTap;
  final VoidCallback? onPlayAgainTap;
  final VoidCallback? onBackToHomeTap;

  @override
  Widget build(BuildContext context) {
    return FinalGroupChallengeModePage(
      submission: submission,
      punishedLabel: punishedLabel,
      onSendTap: onSendTap,
      onPlayAgainTap: onPlayAgainTap,
      onBackToHomeTap: onBackToHomeTap,
    );
  }
}
