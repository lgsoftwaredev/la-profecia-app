import '../../../profile/domain/entities/user_stats_summary.dart';

abstract class GameHistoryRepository {
  Future<void> registerFinishedMatch({
    required String sessionId,
    required DateTime playedAt,
    required String resultLabel,
    required int scoreDelta,
    required bool won,
    String? headline,
  });

  Future<UserStatsSummary> readSummary();
}
