import '../../../../core/constants/game_rules.dart';

enum MatchLevel { cielo, tierra, infierno, inframundo }

extension MatchLevelX on MatchLevel {
  int get points => switch (this) {
    MatchLevel.cielo => GameRules.cieloPoints,
    MatchLevel.tierra => GameRules.tierraPoints,
    MatchLevel.infierno => GameRules.infiernoPoints,
    MatchLevel.inframundo => GameRules.inframundoPoints,
  };

  bool get isPremium => this != MatchLevel.cielo;

  int get requiredCompletedRounds => switch (this) {
    MatchLevel.cielo => 0,
    MatchLevel.tierra => 0,
    MatchLevel.infierno => 0,
    MatchLevel.inframundo => GameRules.unlockInframundoAfterCompletedRounds,
  };
}
