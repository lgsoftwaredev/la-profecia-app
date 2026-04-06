import '../../../game_mode_selection/domain/entities/game_mode.dart';
import 'match_participant.dart';

enum MatchWinnerKind { player, pair }

class MatchFinalResult {
  const MatchFinalResult({
    required this.winnerKind,
    required this.winnerLabel,
    required this.loserLabel,
    required this.scoresByPlayerId,
    required this.winnerPlayer,
    required this.loserPlayer,
    this.winnerPairIndex,
    this.loserPairIndex,
  });

  final MatchWinnerKind winnerKind;
  final String winnerLabel;
  final String loserLabel;
  final Map<int, int> scoresByPlayerId;
  final MatchParticipant? winnerPlayer;
  final MatchParticipant? loserPlayer;
  final int? winnerPairIndex;
  final int? loserPairIndex;

  static MatchFinalResult fromParticipants({
    required GameMode mode,
    required List<MatchParticipant> participants,
  }) {
    final ordered = [...participants]
      ..sort((a, b) => b.score.compareTo(a.score));

    final winner = ordered.isEmpty ? null : ordered.first;
    final loser = ordered.isEmpty ? null : ordered.last;

    if (mode.isCouples) {
      final pairScores = <int, int>{};
      for (final participant in participants) {
        final pairIndex = participant.pairIndex;
        if (pairIndex == null) {
          continue;
        }
        pairScores[pairIndex] =
            (pairScores[pairIndex] ?? 0) + participant.score;
      }

      if (pairScores.isNotEmpty) {
        final sortedPairs = pairScores.entries.toList(growable: false)
          ..sort((a, b) => b.value.compareTo(a.value));

        final winnerPair = sortedPairs.first;
        final loserPair = sortedPairs.last;

        return MatchFinalResult(
          winnerKind: MatchWinnerKind.pair,
          winnerLabel: 'Pareja ${winnerPair.key + 1}',
          loserLabel: 'Pareja ${loserPair.key + 1}',
          winnerPlayer: winner,
          loserPlayer: loser,
          winnerPairIndex: winnerPair.key,
          loserPairIndex: loserPair.key,
          scoresByPlayerId: <int, int>{
            for (final participant in participants)
              participant.id: participant.score,
          },
        );
      }
    }

    return MatchFinalResult(
      winnerKind: MatchWinnerKind.player,
      winnerLabel: winner == null ? '---' : winner.name,
      loserLabel: loser == null ? '---' : loser.name,
      winnerPlayer: winner,
      loserPlayer: loser,
      scoresByPlayerId: <int, int>{
        for (final participant in participants)
          participant.id: participant.score,
      },
    );
  }
}
