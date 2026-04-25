import 'package:flutter/material.dart';

import '../../../../core/constants/game_rules.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../match_play/domain/entities/match_level.dart';
import '../../../profile/domain/entities/editable_profile.dart';

enum GameStyleTheme { cielo, tierra, infierno, inframundo }

extension GameStyleThemeX on GameStyleTheme {
  String get label => switch (this) {
    GameStyleTheme.cielo => 'CIELO',
    GameStyleTheme.tierra => 'TIERRA',
    GameStyleTheme.infierno => 'INFIERNO',
    GameStyleTheme.inframundo => 'INFRAMUNDO',
  };

  String get subtitle => switch (this) {
    GameStyleTheme.cielo => 'Nivel fácil',
    GameStyleTheme.tierra => 'Nivel intermedio',
    GameStyleTheme.infierno => 'Nivel difícil',
    GameStyleTheme.inframundo => 'Nivel extremo',
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

  MatchLevel get toMatchLevel => switch (this) {
    GameStyleTheme.cielo => MatchLevel.cielo,
    GameStyleTheme.tierra => MatchLevel.tierra,
    GameStyleTheme.infierno => MatchLevel.infierno,
    GameStyleTheme.inframundo => MatchLevel.inframundo,
  };
}

extension MatchLevelToGameStyleThemeX on MatchLevel {
  GameStyleTheme get toGameStyleTheme => switch (this) {
    MatchLevel.cielo => GameStyleTheme.cielo,
    MatchLevel.tierra => GameStyleTheme.tierra,
    MatchLevel.infierno => GameStyleTheme.infierno,
    MatchLevel.inframundo => GameStyleTheme.inframundo,
  };
}

class PlayerConfig {
  const PlayerConfig({
    required this.id,
    required this.name,
    required this.avatarAssetPath,
    this.pairIndex,
    this.authUserId,
    this.isAuthenticatedUser = false,
    this.identity,
    this.attraction,
  });

  final int id;
  final String name;
  final String avatarAssetPath;
  final int? pairIndex;
  final String? authUserId;
  final bool isAuthenticatedUser;
  final ProfileIdentity? identity;
  final ProfileAttraction? attraction;

  PlayerConfig copyWith({
    int? id,
    String? name,
    String? avatarAssetPath,
    int? pairIndex,
    String? authUserId,
    bool? isAuthenticatedUser,
    ProfileIdentity? identity,
    bool clearIdentity = false,
    ProfileAttraction? attraction,
    bool clearAttraction = false,
  }) {
    return PlayerConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarAssetPath: avatarAssetPath ?? this.avatarAssetPath,
      pairIndex: pairIndex ?? this.pairIndex,
      authUserId: authUserId ?? this.authUserId,
      isAuthenticatedUser: isAuthenticatedUser ?? this.isAuthenticatedUser,
      identity: clearIdentity ? null : (identity ?? this.identity),
      attraction: clearAttraction ? null : (attraction ?? this.attraction),
    );
  }
}

class GameSetupState {
  const GameSetupState({
    required this.mode,
    required this.groupCount,
    required this.players,
    required this.enabledThemes,
    required this.isPremium,
    required this.showValidationErrors,
  });

  final GameMode mode;
  final int groupCount;
  final List<PlayerConfig> players;
  final List<GameStyleTheme> enabledThemes;
  final bool isPremium;
  final bool showValidationErrors;

  int get minGroupCount =>
      mode.isFriends ? GameRules.minFriendsParticipants : GameRules.minCouples;
  int get maxGroupCount =>
      mode.isFriends ? GameRules.maxFriendsParticipants : GameRules.maxCouples;
  int get totalPlayers => mode.isFriends ? groupCount : groupCount * 2;

  String get countTitle => mode.isFriends ? 'jugadores' : 'parejas';
  String get participantRangeLabel => mode.isFriends
      ? 'De ${GameRules.minFriendsParticipants} a ${GameRules.maxFriendsParticipants} jugadores.'
      : 'De ${GameRules.minCouples} a ${GameRules.maxCouples} parejas.';

  bool get canStart => players.every((player) => player.name.trim().isNotEmpty);

  bool themeIsLocked(GameStyleTheme theme) => theme.isPremiumOnly && !isPremium;
  bool isThemeEnabled(GameStyleTheme theme) => enabledThemes.contains(theme);
  GameStyleTheme get preferredTheme =>
      enabledThemes.isEmpty ? GameStyleTheme.cielo : enabledThemes.first;

  GameSetupState copyWith({
    GameMode? mode,
    int? groupCount,
    List<PlayerConfig>? players,
    List<GameStyleTheme>? enabledThemes,
    bool? isPremium,
    bool? showValidationErrors,
  }) {
    return GameSetupState(
      mode: mode ?? this.mode,
      groupCount: groupCount ?? this.groupCount,
      players: players ?? this.players,
      enabledThemes: enabledThemes ?? this.enabledThemes,
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
    required this.enabledThemes,
  });

  final GameMode mode;
  final List<PlayerConfig> players;
  final List<List<PlayerConfig>> pairs;
  final List<GameStyleTheme> enabledThemes;

  GameStyleTheme get preferredTheme =>
      enabledThemes.isEmpty ? GameStyleTheme.cielo : enabledThemes.first;
}
