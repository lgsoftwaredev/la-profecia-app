import 'dart:math';

import '../../domain/entities/game_prompt.dart';
import '../../domain/entities/match_level.dart';
import '../../domain/repositories/friends_content_repository.dart';
import '../seeds/friends_prompts_seed.dart';

class LocalFriendsContentRepository implements FriendsContentRepository {
  LocalFriendsContentRepository({Random? random})
    : _random = random ?? Random();

  final Random _random;

  @override
  Future<GamePrompt> pickPrompt({
    required MatchLevel level,
    required MatchPromptKind kind,
  }) async {
    final source = kind == MatchPromptKind.question
        ? kFriendsQuestionsSeed
        : kFriendsChallengesSeed;
    final entries = source[level] ?? const <String>[];
    if (entries.isEmpty) {
      return GamePrompt(
        id: 'friends-${kind.name}-${level.name}-fallback',
        text: 'No hay contenido cargado para este nivel todavia.',
        level: level,
        kind: kind,
      );
    }

    final index = _random.nextInt(entries.length);
    return GamePrompt(
      id: 'friends-${kind.name}-${level.name}-$index',
      text: entries[index],
      level: level,
      kind: kind,
    );
  }
}
