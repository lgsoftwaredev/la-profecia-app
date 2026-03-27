import 'package:flutter/material.dart';

import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../player_setup/domain/entities/game_setup_models.dart';
import 'round_score_summary_couple_page.dart';
import 'round_score_summary_friends_page.dart';

class RoundScoreSummaryPage extends StatelessWidget {
  const RoundScoreSummaryPage({
    required this.submission,
    required this.completedPlayerId,
    required this.scoresByPlayerId,
    this.round = 1,
    this.gainedPoints = 10,
    this.didComplete = true,
    super.key,
  });

  final GameSetupSubmission submission;
  final int completedPlayerId;
  final Map<int, int> scoresByPlayerId;
  final int round;
  final int gainedPoints;
  final bool didComplete;

  @override
  Widget build(BuildContext context) {
    if (submission.mode.isFriends) {
      return RoundScoreSummaryFriendsPage(
        submission: submission,
        completedPlayerId: completedPlayerId,
        scoresByPlayerId: scoresByPlayerId,
        round: round,
        gainedPoints: gainedPoints,
        didComplete: didComplete,
      );
    }

    return RoundScoreSummaryCouplePage(
      submission: submission,
      completedPlayerId: completedPlayerId,
      scoresByPlayerId: scoresByPlayerId,
      round: round,
      gainedPoints: gainedPoints,
      didComplete: didComplete,
    );
  }
}
