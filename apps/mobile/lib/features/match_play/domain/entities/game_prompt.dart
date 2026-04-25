import 'match_level.dart';

enum MatchPromptKind { question, challenge }

class GamePrompt {
  const GamePrompt({
    required this.id,
    required this.text,
    required this.level,
    required this.kind,
    this.remoteContentId,
    this.templateTokens = const <String>[],
    this.timerSeconds,
    this.hasMatchEffect = false,
  });

  final String id;
  final String text;
  final MatchLevel level;
  final MatchPromptKind kind;
  final int? remoteContentId;
  final List<String> templateTokens;
  final int? timerSeconds;
  final bool hasMatchEffect;
}
