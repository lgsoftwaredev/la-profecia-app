import 'dart:math';

import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../../domain/entities/game_prompt.dart';
import '../../domain/entities/match_level.dart';
import '../../domain/entities/match_participant.dart';
import '../../domain/entities/match_result.dart';
import '../../domain/entities/match_session.dart';
import '../../domain/entities/match_turn.dart';

class GameEngine {
  GameEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  MatchSession createMatch({required GameSetupSubmission setup}) {
    final participants = setup.players
        .map(
          (player) => MatchParticipant(
            id: player.id,
            name: player.name.trim().isEmpty
                ? 'Jugador ${player.id}'
                : player.name.trim(),
            pairIndex: player.pairIndex,
            authUserId: player.authUserId,
            isAuthenticatedUser: player.isAuthenticatedUser,
          ),
        )
        .toList(growable: false);

    final firstId = participants.isEmpty ? 1 : participants.first.id;
    final activeCount = participants.length;

    return MatchSession(
      id: _createSessionId(),
      mode: setup.mode,
      participants: participants,
      currentParticipantId: firstId,
      roundNumber: 1,
      completedRounds: 0,
      remainingTurnsInRound: activeCount,
      turnsPlayed: 0,
      status: MatchSessionStatus.active,
      startedAt: DateTime.now(),
      pendingTurn: null,
    );
  }

  List<MatchLevel> availableLevels({
    required int completedRounds,
    required bool hasPremium,
  }) {
    return MatchLevel.values
        .where((level) {
          final unlockedByRound =
              completedRounds >= level.requiredCompletedRounds;
          if (!unlockedByRound) {
            return false;
          }
          if (level.isPremium && !hasPremium) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  MatchLevel resolveLevel({
    required MatchSession session,
    required bool hasPremium,
    MatchLevel? preferred,
    bool randomSelection = false,
  }) {
    final available = availableLevels(
      completedRounds: session.completedRounds,
      hasPremium: hasPremium,
    );

    if (available.isEmpty) {
      return MatchLevel.cielo;
    }

    if (randomSelection) {
      return available[_random.nextInt(available.length)];
    }

    if (preferred != null && available.contains(preferred)) {
      return preferred;
    }

    return available.first;
  }

  MatchSession createTurn({
    required MatchSession session,
    required MatchPromptKind promptKind,
    required MatchLevel level,
    required GamePrompt prompt,
  }) {
    if (session.pendingTurn != null || session.isFinished) {
      return session;
    }

    final turn = MatchTurn(
      turnNumber: session.turnsPlayed + 1,
      roundNumber: session.roundNumber,
      participantId: session.currentParticipantId,
      level: level,
      promptKind: promptKind,
      promptText: prompt.text,
      remoteContentId: prompt.remoteContentId,
    );

    return session.copyWith(pendingTurn: turn);
  }

  MatchTurnResolution resolveTurn({
    required MatchSession session,
    required bool didComplete,
  }) {
    final turn = session.pendingTurn;
    if (turn == null) {
      return MatchTurnResolution(
        session: session,
        completedPlayerId: session.currentParticipantId,
        pointsDelta: 0,
        didComplete: didComplete,
        round: session.roundNumber,
        roundCompleted: false,
        eliminated: false,
      );
    }

    final participants = [...session.participants];
    final participantIndex = participants.indexWhere(
      (participant) => participant.id == turn.participantId,
    );

    if (participantIndex == -1) {
      return MatchTurnResolution(
        session: session.copyWith(clearPendingTurn: true),
        completedPlayerId: turn.participantId,
        pointsDelta: 0,
        didComplete: didComplete,
        round: session.roundNumber,
        roundCompleted: false,
        eliminated: false,
      );
    }

    var participant = participants[participantIndex];
    var delta = 0;
    var eliminated = false;

    if (didComplete) {
      delta = turn.level.points;
      participant = participant.copyWith(score: participant.score + delta);
    } else if (turn.level == MatchLevel.inframundo) {
      delta = -participant.score;
      participant = participant.copyWith(score: 0, isEliminated: true);
      eliminated = true;
    } else {
      final updatedScore = max(0, participant.score - turn.level.points);
      delta = updatedScore - participant.score;
      participant = participant.copyWith(score: updatedScore);
    }

    participants[participantIndex] = participant;

    var remainingTurns = session.remainingTurnsInRound - 1;
    var completedRounds = session.completedRounds;
    var roundNumber = session.roundNumber;
    var roundCompleted = false;

    final activeParticipants = participants
        .where((item) => !item.isEliminated)
        .toList(growable: false);

    if (remainingTurns <= 0) {
      completedRounds += 1;
      roundNumber += 1;
      remainingTurns = activeParticipants.length;
      roundCompleted = true;
    }

    var status = MatchSessionStatus.active;
    DateTime? endedAt;

    if (activeParticipants.length <= 1) {
      status = MatchSessionStatus.finished;
      endedAt = DateTime.now();
    }

    final nextParticipantId = _nextParticipantId(
      activeParticipants: activeParticipants,
      currentId: turn.participantId,
      fallback: turn.participantId,
    );

    final updatedSession = session.copyWith(
      participants: participants,
      currentParticipantId: nextParticipantId,
      roundNumber: roundNumber,
      completedRounds: completedRounds,
      remainingTurnsInRound: remainingTurns,
      turnsPlayed: session.turnsPlayed + 1,
      status: status,
      endedAt: endedAt,
      clearPendingTurn: true,
    );

    return MatchTurnResolution(
      session: updatedSession,
      completedPlayerId: turn.participantId,
      pointsDelta: delta,
      didComplete: didComplete,
      round: turn.roundNumber,
      roundCompleted: roundCompleted,
      eliminated: eliminated,
    );
  }

  MatchSession finishMatch(MatchSession session) {
    if (session.isFinished) {
      return session;
    }

    return session.copyWith(
      status: MatchSessionStatus.finished,
      endedAt: DateTime.now(),
      clearPendingTurn: true,
    );
  }

  MatchFinalResult buildFinalResult(MatchSession session) {
    return MatchFinalResult.fromParticipants(
      mode: session.mode,
      participants: session.participants,
    );
  }

  String _createSessionId() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    final suffix = _random.nextInt(999999).toString().padLeft(6, '0');
    return 'match-$millis-$suffix';
  }

  int _nextParticipantId({
    required List<MatchParticipant> activeParticipants,
    required int currentId,
    required int fallback,
  }) {
    if (activeParticipants.isEmpty) {
      return fallback;
    }

    final ordered = [...activeParticipants]
      ..sort((a, b) => a.id.compareTo(b.id));
    final currentIndex = ordered.indexWhere((item) => item.id == currentId);
    if (currentIndex == -1) {
      return ordered.first.id;
    }

    final nextIndex = (currentIndex + 1) % ordered.length;
    return ordered[nextIndex].id;
  }
}

class MatchTurnResolution {
  const MatchTurnResolution({
    required this.session,
    required this.completedPlayerId,
    required this.pointsDelta,
    required this.didComplete,
    required this.round,
    required this.roundCompleted,
    required this.eliminated,
  });

  final MatchSession session;
  final int completedPlayerId;
  final int pointsDelta;
  final bool didComplete;
  final int round;
  final bool roundCompleted;
  final bool eliminated;
}
