import '../entities/game_prompt.dart';
import '../entities/match_level.dart';

abstract class CouplesContentRepository {
  Future<GamePrompt> pickPrompt({
    required MatchLevel level,
    required MatchPromptKind kind,
  });
}
