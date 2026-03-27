import 'package:flutter/material.dart';

import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../widgets/final_judgment_mode_page.dart';

class FinalJudgmentPage extends StatelessWidget {
  const FinalJudgmentPage({
    required this.submission,
    required this.scoresByPlayerId,
    this.onProphecyChallengeTap,
    this.onGroupDecisionTap,
    super.key,
  });

  final GameSetupSubmission submission;
  final Map<int, int> scoresByPlayerId;
  final VoidCallback? onProphecyChallengeTap;
  final VoidCallback? onGroupDecisionTap;

  @override
  Widget build(BuildContext context) {
    return FinalJudgmentModePage(
      submission: submission,
      scoresByPlayerId: scoresByPlayerId,
      onProphecyChallengeTap: onProphecyChallengeTap,
      onGroupDecisionTap: onGroupDecisionTap,
    );
  }
}
