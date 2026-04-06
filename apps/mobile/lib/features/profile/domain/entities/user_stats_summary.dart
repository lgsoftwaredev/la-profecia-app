class UserStatsSummary {
  const UserStatsSummary({
    required this.matchesPlayed,
    required this.accumulatedScore,
    required this.wins,
    required this.losses,
    required this.history,
  });

  final int matchesPlayed;
  final int accumulatedScore;
  final int wins;
  final int losses;
  final List<GameHistoryItem> history;
}

class GameHistoryItem {
  const GameHistoryItem({
    required this.sessionId,
    required this.playedAt,
    required this.resultLabel,
    required this.scoreDelta,
  });

  final String sessionId;
  final DateTime playedAt;
  final String resultLabel;
  final int scoreDelta;
}
