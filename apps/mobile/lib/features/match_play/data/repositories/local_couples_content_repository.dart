import 'dart:math';

import '../../domain/entities/game_prompt.dart';
import '../../domain/entities/match_level.dart';
import '../../domain/repositories/couples_content_repository.dart';
import '../seeds/couples_prompts_seed.dart';

class LocalCouplesContentRepository implements CouplesContentRepository {
  LocalCouplesContentRepository({Random? random})
    : _random = random ?? Random();

  final Random _random;

  @override
  Future<GamePrompt> pickPrompt({
    required MatchLevel level,
    required MatchPromptKind kind,
  }) async {
    final source = kind == MatchPromptKind.question
        ? kCouplesQuestionsSeed
        : kCouplesChallengesSeed;
    final entries = source[level] ?? const <String>[];
    if (entries.isEmpty) {
      return GamePrompt(
        id: 'couples-${kind.name}-${level.name}-fallback',
        text: 'No hay contenido cargado para este nivel todavia.',
        level: level,
        kind: kind,
      );
    }

    final index = _random.nextInt(entries.length);
    return GamePrompt(
      id: 'couples-${kind.name}-${level.name}-$index',
      text: entries[index],
      level: level,
      kind: kind,
    );
  }
}
