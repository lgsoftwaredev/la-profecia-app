import '../entities/match_result.dart';
import '../entities/match_session.dart';

abstract class ActiveMatchRepository {
  Future<MatchSession> save(MatchSession session);
  Future<MatchSession?> loadActive();
  Future<void> clear();
  Future<void> persistFinalResult({
    required MatchSession session,
    required MatchFinalResult result,
  });
  Future<void> persistFinalPenalty({
    required MatchSession session,
    required String penaltyText,
  });
}
