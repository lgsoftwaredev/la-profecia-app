import 'game_prompt.dart';
import 'match_level.dart';

enum MatchTurnOutcome { completed, failed }

class MatchTurn {
  const MatchTurn({
    required this.turnNumber,
    required this.roundNumber,
    required this.participantId,
    required this.level,
    required this.promptKind,
    required this.promptText,
    this.remoteContentId,
    this.timerSeconds,
    this.hasMatchEffect = false,
  });

  final int turnNumber;
  final int roundNumber;
  final int participantId;
  final MatchLevel level;
  final MatchPromptKind promptKind;
  final String promptText;
  final int? remoteContentId;
  final int? timerSeconds;
  final bool hasMatchEffect;

  MatchTurn copyWith({
    int? turnNumber,
    int? roundNumber,
    int? participantId,
    MatchLevel? level,
    MatchPromptKind? promptKind,
    String? promptText,
    int? remoteContentId,
    int? timerSeconds,
    bool? hasMatchEffect,
  }) {
    return MatchTurn(
      turnNumber: turnNumber ?? this.turnNumber,
      roundNumber: roundNumber ?? this.roundNumber,
      participantId: participantId ?? this.participantId,
      level: level ?? this.level,
      promptKind: promptKind ?? this.promptKind,
      promptText: promptText ?? this.promptText,
      remoteContentId: remoteContentId ?? this.remoteContentId,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      hasMatchEffect: hasMatchEffect ?? this.hasMatchEffect,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'turnNumber': turnNumber,
    'roundNumber': roundNumber,
    'participantId': participantId,
    'level': level.name,
    'promptKind': promptKind.name,
    'promptText': promptText,
    'remoteContentId': remoteContentId,
    'timerSeconds': timerSeconds,
    'hasMatchEffect': hasMatchEffect,
  };

  static MatchTurn fromJson(Map<String, dynamic> json) {
    final timerValue = json['timerSeconds'];
    final timerSeconds = timerValue is num ? timerValue.toInt() : null;
    return MatchTurn(
      turnNumber: json['turnNumber'] as int,
      roundNumber: json['roundNumber'] as int,
      participantId: json['participantId'] as int,
      level: MatchLevel.values.byName(json['level'] as String),
      promptKind: MatchPromptKind.values.byName(json['promptKind'] as String),
      promptText: json['promptText'] as String,
      remoteContentId: json['remoteContentId'] as int?,
      timerSeconds: timerSeconds,
      hasMatchEffect: json['hasMatchEffect'] == true,
    );
  }
}
