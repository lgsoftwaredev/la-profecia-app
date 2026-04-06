import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/match_result.dart';
import '../../domain/entities/match_session.dart';
import '../../domain/repositories/active_match_repository.dart';
import '../datasources/supabase_match_datasource.dart';

class HybridActiveMatchRepository implements ActiveMatchRepository {
  HybridActiveMatchRepository({
    required ActiveMatchRepository localRepository,
    required SupabaseMatchDataSource remoteDataSource,
    required SupabaseClient? client,
  }) : _localRepository = localRepository,
       _remoteDataSource = remoteDataSource,
       _client = client;

  final ActiveMatchRepository _localRepository;
  final SupabaseMatchDataSource _remoteDataSource;
  final SupabaseClient? _client;

  @override
  Future<MatchSession> save(MatchSession session) async {
    final cached = await _localRepository.loadActive();
    final previous = cached != null && cached.id == session.id ? cached : null;
    var next = session;

    if (_shouldPersistRemotely) {
      try {
        if (next.remoteSessionId == null) {
          final bootstrap = await _remoteDataSource.bootstrapSession(next);
          next = next.copyWith(
            remoteSessionId: bootstrap.remoteSessionId,
            remoteRoundId: bootstrap.remoteRoundId,
            remotePlayerIdsByParticipantId:
                bootstrap.remotePlayerIdsByParticipantId,
          );
        }

        final startedTurn = _isTurnStarted(previous, next);
        if (startedTurn && next.pendingTurn != null) {
          final remoteRoundId =
              next.remoteRoundId ??
              await _remoteDataSource.ensureRound(
                remoteSessionId: next.remoteSessionId!,
                roundNumber: next.pendingTurn!.roundNumber,
              );
          next = next.copyWith(remoteRoundId: remoteRoundId);
          await _remoteDataSource.persistTurnStarted(
            session: next,
            turn: next.pendingTurn!,
          );
        }

        final resolvedTurn = _isTurnResolved(previous, next);
        if (resolvedTurn && previous?.pendingTurn != null) {
          final resolvedRound = previous!.pendingTurn!.roundNumber;
          await _remoteDataSource.persistTurnResolved(
            session: next,
            resolvedRoundNumber: resolvedRound,
          );
          if (next.roundNumber > resolvedRound || next.isFinished) {
            next = next.copyWith(remoteRoundId: null);
          }
        }

        final finishedNow =
            previous != null && !previous.isFinished && next.isFinished;
        if (finishedNow && !resolvedTurn) {
          await _remoteDataSource.markSessionFinished(next);
          next = next.copyWith(remoteRoundId: null);
        }
      } catch (_) {
        // Local gameplay must continue if remote persistence fails.
      }
    }

    await _localRepository.save(next);
    return next;
  }

  @override
  Future<MatchSession?> loadActive() => _localRepository.loadActive();

  @override
  Future<void> clear() => _localRepository.clear();

  @override
  Future<void> persistFinalResult({
    required MatchSession session,
    required MatchFinalResult result,
  }) async {
    if (!_shouldPersistRemotely || session.remoteSessionId == null) {
      return;
    }

    try {
      await _remoteDataSource.persistFinalResult(
        session: session,
        result: result,
      );
    } catch (_) {
      // Final judgment sync should not break local flow.
    }
  }

  @override
  Future<void> persistFinalPenalty({
    required MatchSession session,
    required String penaltyText,
  }) async {
    if (!_shouldPersistRemotely || session.remoteSessionId == null) {
      return;
    }

    await _remoteDataSource.persistFinalGroupPenalty(
      session: session,
      penaltyText: penaltyText,
    );
  }

  bool get _shouldPersistRemotely =>
      _client != null && _client.auth.currentUser != null;

  bool _isTurnStarted(MatchSession? previous, MatchSession next) {
    if (next.pendingTurn == null) {
      return false;
    }
    if (previous == null || previous.pendingTurn == null) {
      return true;
    }
    final previousTurn = previous.pendingTurn!;
    final nextTurn = next.pendingTurn!;
    return previousTurn.turnNumber != nextTurn.turnNumber ||
        previousTurn.roundNumber != nextTurn.roundNumber ||
        previousTurn.participantId != nextTurn.participantId ||
        previousTurn.level != nextTurn.level ||
        previousTurn.promptKind != nextTurn.promptKind ||
        previousTurn.remoteContentId != nextTurn.remoteContentId ||
        previousTurn.promptText != nextTurn.promptText;
  }

  bool _isTurnResolved(MatchSession? previous, MatchSession next) {
    if (previous == null || previous.pendingTurn == null) {
      return false;
    }
    if (next.pendingTurn != null) {
      return false;
    }
    return next.turnsPlayed > previous.turnsPlayed;
  }
}
