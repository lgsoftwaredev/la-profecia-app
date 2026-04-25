import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../profile/domain/entities/user_stats_summary.dart';

class SupabaseHistoryDataSource {
  SupabaseHistoryDataSource({required SupabaseClient? client})
    : _client = client;

  final SupabaseClient? _client;

  Future<void> registerFinishedMatch({
    required String sessionId,
    required DateTime playedAt,
    required String resultLabel,
    required int scoreDelta,
    required bool won,
    String? headline,
  }) async {
    final client = _requiredClient();
    final userId = _requireUserId(client);

    await client.from('GameHistorySummary').upsert(<String, dynamic>{
      'userId': userId,
      'sessionId': sessionId,
      'resultLabel': resultLabel,
      'scoreDelta': scoreDelta,
      'headline': headline,
      'playedAt': playedAt.toUtc().toIso8601String(),
    }, onConflict: 'userId,sessionId');

    final currentStats = await client
        .from('UserStats')
        .select('matchesPlayed,accumulatedScore,wins,losses')
        .eq('userId', userId)
        .maybeSingle();

    final currentMatchesPlayed = (currentStats?['matchesPlayed'] as int?) ?? 0;
    final currentAccumulatedScore =
        (currentStats?['accumulatedScore'] as int?) ?? 0;
    final currentWins = (currentStats?['wins'] as int?) ?? 0;
    final currentLosses = (currentStats?['losses'] as int?) ?? 0;

    await client.from('UserStats').upsert(<String, dynamic>{
      'userId': userId,
      'matchesPlayed': currentMatchesPlayed + 1,
      'accumulatedScore': currentAccumulatedScore + scoreDelta,
      'wins': currentWins + (won ? 1 : 0),
      'losses': currentLosses + (won ? 0 : 1),
    }, onConflict: 'userId');
  }

  Future<UserStatsSummary> readSummary() async {
    final client = _requiredClient();
    final userId = _requireUserId(client);

    final stats = await client
        .from('UserStats')
        .select('matchesPlayed,accumulatedScore,wins,losses')
        .eq('userId', userId)
        .maybeSingle();

    final historyRows = await client
        .from('GameHistorySummary')
        .select('sessionId,playedAt,resultLabel,scoreDelta,headline')
        .eq('userId', userId)
        .order('playedAt', ascending: false);

    final history = <GameHistoryItem>[];
    var accumulatedScore = 0;
    var wins = 0;
    var losses = 0;
    for (final row in historyRows as List<dynamic>) {
      final item = row as Map<String, dynamic>;
      final scoreDelta = (item['scoreDelta'] as int?) ?? 0;
      final resultLabel = item['resultLabel'] as String? ?? 'Sin resultado';
      accumulatedScore += scoreDelta;
      if (_didWin(resultLabel: resultLabel, scoreDelta: scoreDelta)) {
        wins += 1;
      } else {
        losses += 1;
      }

      history.add(
        GameHistoryItem(
          sessionId: item['sessionId'] as String,
          playedAt:
              DateTime.tryParse(item['playedAt'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
          resultLabel: resultLabel,
          scoreDelta: scoreDelta,
          headline: item['headline'] as String?,
        ),
      );
    }

    return UserStatsSummary(
      matchesPlayed: (stats?['matchesPlayed'] as int?) ?? history.length,
      accumulatedScore:
          (stats?['accumulatedScore'] as int?) ?? accumulatedScore,
      wins: (stats?['wins'] as int?) ?? wins,
      losses: (stats?['losses'] as int?) ?? losses,
      history: history,
    );
  }

  bool _didWin({required String resultLabel, required int scoreDelta}) {
    final normalized = resultLabel.trim().toLowerCase();
    if (normalized.contains('perdid') ||
        normalized.contains('derrot') ||
        normalized == 'loss' ||
        normalized == 'lost') {
      return false;
    }
    if (normalized.contains('ganad') ||
        normalized.contains('victor') ||
        normalized == 'win' ||
        normalized == 'won') {
      return true;
    }
    if (scoreDelta > 0) {
      return true;
    }
    if (scoreDelta < 0) {
      return false;
    }
    return false;
  }

  SupabaseClient _requiredClient() {
    final client = _client;
    if (client == null) {
      throw const AppFailure('Servicio de contenido no disponible.');
    }
    return client;
  }

  String _requireUserId(SupabaseClient client) {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw const AppFailure(
        'Se requiere sesion autenticada para leer historial remoto.',
      );
    }
    return userId;
  }
}
