import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../domain/entities/game_prompt.dart';
import '../../domain/entities/match_result.dart';
import '../../domain/entities/match_session.dart';
import '../../domain/entities/match_turn.dart';

class RemoteMatchBootstrap {
  const RemoteMatchBootstrap({
    required this.remoteSessionId,
    required this.remoteRoundId,
    required this.remotePlayerIdsByParticipantId,
  });

  final String remoteSessionId;
  final String remoteRoundId;
  final Map<int, String> remotePlayerIdsByParticipantId;
}

class SupabaseMatchDataSource {
  SupabaseMatchDataSource({required SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  Map<String, int>? _modeIdsByCode;

  Future<RemoteMatchBootstrap> bootstrapSession(MatchSession session) async {
    final client = _requiredClient();
    final user = client.auth.currentUser;
    if (user == null) {
      throw const AppFailure(
        'Se requiere usuario autenticado para persistir partida.',
      );
    }

    final modeId = await _resolveModeId(session.mode);
    final gameSessionRow = await client
        .from('GameSession')
        .insert(<String, dynamic>{
          'ownerUserId': user.id,
          'modeId': modeId,
          'status': 'ACTIVE',
          'startedAt': session.startedAt.toUtc().toIso8601String(),
        })
        .select('id')
        .single();
    final remoteSessionId = gameSessionRow['id'] as String?;
    if (remoteSessionId == null) {
      throw const AppFailure('No se pudo crear la sesion remota.');
    }

    final playerRowsPayload = session.participants
        .map(
          (participant) => <String, dynamic>{
            'sessionId': remoteSessionId,
            'displayName': participant.name,
            'seatOrder': participant.id,
            'pairIndex': participant.pairIndex,
            'profileId': participant.authUserId,
            'isEliminated': participant.isEliminated,
          },
        )
        .toList(growable: false);

    final playerRows = await client
        .from('SessionPlayer')
        .insert(playerRowsPayload)
        .select('id,seatOrder');

    final remotePlayerIdsByParticipantId = <int, String>{};
    for (final row in playerRows as List<dynamic>) {
      final item = row as Map<String, dynamic>;
      final seatOrder = item['seatOrder'] as int?;
      final playerId = item['id'] as String?;
      if (seatOrder != null && playerId != null) {
        remotePlayerIdsByParticipantId[seatOrder] = playerId;
      }
    }
    if (remotePlayerIdsByParticipantId.isEmpty) {
      throw const AppFailure('No se pudieron crear jugadores remotos.');
    }

    final scoreRowsPayload = <Map<String, dynamic>>[];
    for (final participant in session.participants) {
      final remotePlayerId = remotePlayerIdsByParticipantId[participant.id];
      if (remotePlayerId == null) {
        continue;
      }
      scoreRowsPayload.add(<String, dynamic>{
        'sessionId': remoteSessionId,
        'playerId': remotePlayerId,
        'score': participant.score,
      });
    }
    if (scoreRowsPayload.isNotEmpty) {
      await client.from('SessionScore').insert(scoreRowsPayload);
    }

    final roundId = await ensureRound(
      remoteSessionId: remoteSessionId,
      roundNumber: session.roundNumber,
    );

    return RemoteMatchBootstrap(
      remoteSessionId: remoteSessionId,
      remoteRoundId: roundId,
      remotePlayerIdsByParticipantId: remotePlayerIdsByParticipantId,
    );
  }

  Future<String> ensureRound({
    required String remoteSessionId,
    required int roundNumber,
  }) async {
    final client = _requiredClient();

    final existing = await client
        .from('SessionRound')
        .select('id')
        .eq('sessionId', remoteSessionId)
        .eq('roundNumber', roundNumber)
        .maybeSingle();
    if (existing != null && existing['id'] is String) {
      return existing['id'] as String;
    }

    final created = await client
        .from('SessionRound')
        .insert(<String, dynamic>{
          'sessionId': remoteSessionId,
          'roundNumber': roundNumber,
        })
        .select('id')
        .single();
    final roundId = created['id'] as String?;
    if (roundId == null) {
      throw const AppFailure('No se pudo crear la ronda remota.');
    }
    return roundId;
  }

  Future<void> persistTurnStarted({
    required MatchSession session,
    required MatchTurn turn,
  }) async {
    final client = _requiredClient();
    final remoteSessionId = session.remoteSessionId;
    final remotePlayerId =
        session.remotePlayerIdsByParticipantId[turn.participantId];
    if (remoteSessionId == null || remotePlayerId == null) {
      throw const AppFailure('No hay vinculacion remota de partida activa.');
    }

    final roundId =
        session.remoteRoundId ??
        await ensureRound(
          remoteSessionId: remoteSessionId,
          roundNumber: turn.roundNumber,
        );

    await client.from('SessionTurn').insert(<String, dynamic>{
      'sessionId': remoteSessionId,
      'roundId': roundId,
      'playerId': remotePlayerId,
      'contentType': turn.promptKind == MatchPromptKind.question
          ? 'QUESTION'
          : 'CHALLENGE',
      'questionId': turn.promptKind == MatchPromptKind.question
          ? turn.remoteContentId
          : null,
      'challengeId': turn.promptKind == MatchPromptKind.challenge
          ? turn.remoteContentId
          : null,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> persistTurnResolved({
    required MatchSession session,
    required int resolvedRoundNumber,
  }) async {
    final client = _requiredClient();
    final remoteSessionId = session.remoteSessionId;
    if (remoteSessionId == null) {
      return;
    }

    for (final participant in session.participants) {
      final remotePlayerId =
          session.remotePlayerIdsByParticipantId[participant.id];
      if (remotePlayerId == null) {
        continue;
      }

      await client.from('SessionScore').upsert(<String, dynamic>{
        'sessionId': remoteSessionId,
        'playerId': remotePlayerId,
        'score': participant.score,
      }, onConflict: 'sessionId,playerId');

      await client
          .from('SessionPlayer')
          .update(<String, dynamic>{
            'isEliminated': participant.isEliminated,
            'eliminatedAt': participant.isEliminated
                ? DateTime.now().toUtc().toIso8601String()
                : null,
          })
          .eq('id', remotePlayerId);
    }

    if (session.roundNumber > resolvedRoundNumber) {
      await client
          .from('SessionRound')
          .update(<String, dynamic>{
            'endedAt': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('sessionId', remoteSessionId)
          .eq('roundNumber', resolvedRoundNumber);
    }

    if (session.isFinished) {
      await client
          .from('GameSession')
          .update(<String, dynamic>{
            'status': 'FINISHED',
            'endedAt': (session.endedAt ?? DateTime.now())
                .toUtc()
                .toIso8601String(),
          })
          .eq('id', remoteSessionId);
    }
  }

  Future<void> persistFinalResult({
    required MatchSession session,
    required MatchFinalResult result,
  }) async {
    final client = _requiredClient();
    final remoteSessionId = session.remoteSessionId;
    if (remoteSessionId == null) {
      return;
    }

    final winnerRemotePlayerId = result.winnerPlayer == null
        ? null
        : session.remotePlayerIdsByParticipantId[result.winnerPlayer!.id];
    final loserRemotePlayerId = result.loserPlayer == null
        ? null
        : session.remotePlayerIdsByParticipantId[result.loserPlayer!.id];

    await client.from('FinalJudgment').upsert(<String, dynamic>{
      'sessionId': remoteSessionId,
      'winnerKind': result.winnerKind == MatchWinnerKind.player
          ? 'PLAYER'
          : 'PAIR',
      'winnerPlayerId': winnerRemotePlayerId,
      'winnerPairIndex': result.winnerPairIndex,
      'loserPlayerId': loserRemotePlayerId,
      'loserPairIndex': result.loserPairIndex,
    }, onConflict: 'sessionId');
  }

  Future<void> persistFinalGroupPenalty({
    required MatchSession session,
    required String penaltyText,
  }) async {
    final client = _requiredClient();
    final remoteSessionId = session.remoteSessionId;
    final normalizedText = penaltyText.trim();
    if (remoteSessionId == null || normalizedText.isEmpty) {
      return;
    }

    final judgmentRow = await client
        .from('FinalJudgment')
        .select('id')
        .eq('sessionId', remoteSessionId)
        .maybeSingle();
    final judgmentId = judgmentRow?['id'] as String?;
    if (judgmentId == null) {
      throw const AppFailure(
        'No se encontro Juicio Final remoto para guardar el castigo.',
      );
    }

    await client.from('FinalPenalty').upsert(<String, dynamic>{
      'judgmentId': judgmentId,
      'kind': 'GROUP',
      'penaltyText': normalizedText,
    }, onConflict: 'judgmentId');
  }

  Future<void> markSessionFinished(MatchSession session) async {
    final client = _requiredClient();
    final remoteSessionId = session.remoteSessionId;
    if (remoteSessionId == null) {
      return;
    }

    await client
        .from('GameSession')
        .update(<String, dynamic>{
          'status': 'FINISHED',
          'endedAt': (session.endedAt ?? DateTime.now())
              .toUtc()
              .toIso8601String(),
        })
        .eq('id', remoteSessionId);
  }

  SupabaseClient _requiredClient() {
    final client = _client;
    if (client == null) {
      throw const AppFailure('Servicio de contenido no disponible.');
    }
    return client;
  }

  Future<int> _resolveModeId(GameMode mode) async {
    final client = _requiredClient();
    if (_modeIdsByCode == null) {
      final rows = await client.from('GameMode').select('id,code');
      final modeMap = <String, int>{};
      for (final row in rows as List<dynamic>) {
        final item = row as Map<String, dynamic>;
        final code = item['code'] as String?;
        final id = item['id'] as int?;
        if (code != null && id != null) {
          modeMap[code] = id;
        }
      }
      _modeIdsByCode = modeMap;
    }

    final code = switch (mode) {
      GameMode.friends => 'FRIENDS',
      GameMode.couples => 'COUPLES',
    };
    final modeId = _modeIdsByCode?[code];
    if (modeId == null) {
      throw const AppFailure('No se pudo resolver modo de juego remoto.');
    }
    return modeId;
  }
}
