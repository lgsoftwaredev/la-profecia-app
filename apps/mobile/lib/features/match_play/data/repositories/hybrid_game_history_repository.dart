import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../profile/domain/entities/user_stats_summary.dart';
import '../../domain/repositories/game_history_repository.dart';
import '../datasources/supabase_history_datasource.dart';

class HybridGameHistoryRepository implements GameHistoryRepository {
  HybridGameHistoryRepository({
    required GameHistoryRepository localRepository,
    required SupabaseHistoryDataSource remoteDataSource,
    required SupabaseClient? client,
  }) : _localRepository = localRepository,
       _remoteDataSource = remoteDataSource,
       _client = client;

  final GameHistoryRepository _localRepository;
  final SupabaseHistoryDataSource _remoteDataSource;
  final SupabaseClient? _client;

  @override
  Future<void> registerFinishedMatch({
    required String sessionId,
    required DateTime playedAt,
    required String resultLabel,
    required int scoreDelta,
    required bool won,
  }) async {
    if (_shouldUseRemote) {
      try {
        await _remoteDataSource.registerFinishedMatch(
          sessionId: sessionId,
          playedAt: playedAt,
          resultLabel: resultLabel,
          scoreDelta: scoreDelta,
          won: won,
        );
        return;
      } catch (_) {}
    }

    await _localRepository.registerFinishedMatch(
      sessionId: sessionId,
      playedAt: playedAt,
      resultLabel: resultLabel,
      scoreDelta: scoreDelta,
      won: won,
    );
  }

  @override
  Future<UserStatsSummary> readSummary() async {
    if (_shouldUseRemote) {
      try {
        return await _remoteDataSource.readSummary();
      } catch (_) {}
    }

    return _localRepository.readSummary();
  }

  bool get _shouldUseRemote =>
      _client != null && _client.auth.currentUser != null;
}
