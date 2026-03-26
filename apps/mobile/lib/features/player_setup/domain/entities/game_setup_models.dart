import 'package:flutter/material.dart';

import '../../../game_mode_selection/domain/entities/game_mode.dart';

enum GameStyleTheme { cielo, tierra, infierno, inframundo }

extension GameStyleThemeX on GameStyleTheme {
  String get label => switch (this) {
    GameStyleTheme.cielo => 'CIELO',
    GameStyleTheme.tierra => 'TIERRA',
    GameStyleTheme.infierno => 'INFIERNO',
    GameStyleTheme.inframundo => 'INFRAMUNDO',
  };

  String get iconAsset => switch (this) {
    GameStyleTheme.cielo => 'assets/cielo-icon-logo.png',
    GameStyleTheme.tierra => 'assets/tierra-icon-logo.png',
    GameStyleTheme.infierno => 'assets/infierno-icon-logo.png',
    GameStyleTheme.inframundo => 'assets/inframundo-icon-logo.png',
  };

  Color get accentColor => switch (this) {
    GameStyleTheme.cielo => const Color(0xFF1FA7FF),
    GameStyleTheme.tierra => const Color(0xFF69D33E),
    GameStyleTheme.infierno => const Color(0xFFFF4A3A),
    GameStyleTheme.inframundo => const Color(0xFFB26CFF),
  };

  bool get isPremiumOnly => this != GameStyleTheme.cielo;
}

class PlayerConfig {
  const PlayerConfig({required this.id, required this.name, this.pairIndex});

  final int id;
  final String name;
  final int? pairIndex;

  PlayerConfig copyWith({int? id, String? name, int? pairIndex}) {
    return PlayerConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      pairIndex: pairIndex ?? this.pairIndex,
    );
  }
}

class GameSetupState {
  const GameSetupState({
    required this.mode,
    required this.groupCount,
    required this.players,
    required this.selectedTheme,
    required this.isPremium,
    required this.showValidationErrors,
  });

  final GameMode mode;
  final int groupCount;
  final List<PlayerConfig> players;
  final GameStyleTheme selectedTheme;
  final bool isPremium;
  final bool showValidationErrors;

  int get minGroupCount => mode.isFriends ? 3 : 1;
  int get maxGroupCount => mode.isFriends ? 10 : 4;
  int get totalPlayers => mode.isFriends ? groupCount : groupCount * 2;

  String get countTitle => mode.isFriends ? 'jugadores' : 'parejas';
  String get participantRangeLabel =>
      mode.isFriends ? 'De 3 a 10 jugadores.' : '';

  bool get canStart => players.every((player) => player.name.trim().isNotEmpty);

  bool themeIsLocked(GameStyleTheme theme) => theme.isPremiumOnly && !isPremium;

  GameSetupState copyWith({
    GameMode? mode,
    int? groupCount,
    List<PlayerConfig>? players,
    GameStyleTheme? selectedTheme,
    bool? isPremium,
    bool? showValidationErrors,
  }) {
    return GameSetupState(
      mode: mode ?? this.mode,
      groupCount: groupCount ?? this.groupCount,
      players: players ?? this.players,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      isPremium: isPremium ?? this.isPremium,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
    );
  }
}

class GameSetupSubmission {
  const GameSetupSubmission({
    required this.mode,
    required this.players,
    required this.pairs,
    required this.selectedTheme,
  });

  final GameMode mode;
  final List<PlayerConfig> players;
  final List<List<PlayerConfig>> pairs;
  final GameStyleTheme selectedTheme;
}
