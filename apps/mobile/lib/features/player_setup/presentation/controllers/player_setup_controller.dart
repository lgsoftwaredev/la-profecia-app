import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../../core/constants/default_participant_names.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../profile/domain/entities/editable_profile.dart';
import '../../domain/entities/game_setup_models.dart';

class PlayerSetupController extends ChangeNotifier {
  PlayerSetupController({
    required GameMode mode,
    bool isPremium = false,
    String? authenticatedUserId,
    String? authenticatedPlayerName,
  }) : _authenticatedUserId = _normalizeValue(authenticatedUserId),
       _authenticatedPlayerName = _normalizeValue(authenticatedPlayerName) {
    _nameSeedOffset = Random().nextInt(kDefaultParticipantNames.length);
    _avatarSeedOffset = Random().nextInt(1000);
    final initialGroupCount = mode.isFriends ? 4 : 1;
    final initialPlayers = _buildPlayers(
      mode: mode,
      groupCount: initialGroupCount,
    );
    _state = GameSetupState(
      mode: mode,
      groupCount: initialGroupCount,
      players: initialPlayers,
      enabledThemes: const [GameStyleTheme.cielo],
      isPremium: isPremium,
      showValidationErrors: false,
    );
  }

  static const _themeOrder = <GameStyleTheme>[
    GameStyleTheme.cielo,
    GameStyleTheme.tierra,
    GameStyleTheme.infierno,
    GameStyleTheme.inframundo,
  ];
  static const _friendsAvatarPool = <String>[
    'assets/logo-icons-player-setup/friends/Icono 1.png',
    'assets/logo-icons-player-setup/friends/Icono 2.png',
    'assets/logo-icons-player-setup/friends/Icono 3.png',
    'assets/logo-icons-player-setup/friends/Icono 4.png',
    'assets/logo-icons-player-setup/friends/Icono 5.png',
    'assets/logo-icons-player-setup/friends/Icono 6.png',
    'assets/logo-icons-player-setup/friends/Icono 8.png',
    'assets/logo-icons-player-setup/friends/Icono 9.png',
    'assets/logo-icons-player-setup/friends/Icono 11.png',
    'assets/logo-icons-player-setup/friends/Icono 16.png',
    'assets/logo-icons-player-setup/friends/Icono 17.png',
    'assets/logo-icons-player-setup/friends/Icono 18.png',
    'assets/logo-icons-player-setup/friends/Icono 19.png',
    'assets/logo-icons-player-setup/friends/Icono 23.png',
    'assets/logo-icons-player-setup/friends/Icono 26.png',
  ];
  static const _coupleAvatarPool = <String>[
    'assets/logo-icons-player-setup/couple/Icono 7.png',
    'assets/logo-icons-player-setup/couple/Icono 10.png',
    'assets/logo-icons-player-setup/couple/Icono 12.png',
    'assets/logo-icons-player-setup/couple/Icono 13.png',
    'assets/logo-icons-player-setup/couple/Icono 14.png',
    'assets/logo-icons-player-setup/couple/Icono 15.png',
    'assets/logo-icons-player-setup/couple/Icono 20.png',
    'assets/logo-icons-player-setup/couple/Icono 21.png',
    'assets/logo-icons-player-setup/couple/Icono 22.png',
    'assets/logo-icons-player-setup/couple/Icono 24.png',
    'assets/logo-icons-player-setup/couple/Icono 25.png',
  ];

  static String? _normalizeValue(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  late final int _nameSeedOffset;
  late final int _avatarSeedOffset;
  final String? _authenticatedUserId;
  final String? _authenticatedPlayerName;
  final Map<int, String> _nameCacheByPlayerId = <int, String>{};
  late GameSetupState _state;

  GameSetupState get state => _state;
  bool get canIncrement => _state.groupCount < _state.maxGroupCount;
  bool get canDecrement => _state.groupCount > _state.minGroupCount;

  void incrementCount() => _updateGroupCount(_state.groupCount + 1);
  void decrementCount() => _updateGroupCount(_state.groupCount - 1);

  List<PlayerConfig> _buildPlayers({
    required GameMode mode,
    required int groupCount,
    Map<int, PlayerConfig> previousPlayers = const <int, PlayerConfig>{},
  }) {
    final totalPlayers = mode.isFriends ? groupCount : groupCount * 2;

    return List<PlayerConfig>.generate(totalPlayers, (index) {
      final id = index + 1;
      final fallbackName = _defaultNameForId(id);
      final previousPlayer = previousPlayers[id];
      final isAuthenticatedUser = _isAuthenticatedSeat(id);
      final authenticatedPlayerName = _authenticatedPlayerName;
      final seededName = isAuthenticatedUser && authenticatedPlayerName != null
          ? authenticatedPlayerName
          : fallbackName;
      return PlayerConfig(
        id: id,
        name: _nameCacheByPlayerId[id] ?? previousPlayer?.name ?? seededName,
        avatarAssetPath:
            previousPlayer?.avatarAssetPath ??
            _avatarAssetForPlayer(mode: mode, id: id),
        pairIndex: mode.isCouples ? index ~/ 2 : null,
        authUserId: isAuthenticatedUser ? _authenticatedUserId : null,
        isAuthenticatedUser: isAuthenticatedUser,
        identity: previousPlayer?.identity,
        attraction: previousPlayer?.attraction,
      );
    });
  }

  String _avatarAssetForPlayer({required GameMode mode, required int id}) {
    final pool = mode.isFriends ? _friendsAvatarPool : _coupleAvatarPool;
    return pool[(_avatarSeedOffset + id - 1) % pool.length];
  }

  List<GameStyleTheme> _orderedThemes(Iterable<GameStyleTheme> themes) {
    final set = themes.toSet()..add(GameStyleTheme.cielo);
    return _themeOrder.where(set.contains).toList(growable: false);
  }

  String _defaultNameForId(int id) {
    final index = (_nameSeedOffset + id - 1) % kDefaultParticipantNames.length;
    return kDefaultParticipantNames[index];
  }

  bool _isAuthenticatedSeat(int id) => id == 1 && _authenticatedUserId != null;

  void _updateGroupCount(int nextCount) {
    final clamped = nextCount.clamp(_state.minGroupCount, _state.maxGroupCount);
    if (clamped == _state.groupCount) {
      return;
    }

    for (final player in _state.players) {
      final cleanName = player.name.trim();
      if (cleanName.isNotEmpty) {
        _nameCacheByPlayerId[player.id] = cleanName;
      }
    }
    final previousPlayers = <int, PlayerConfig>{
      for (final player in _state.players) player.id: player,
    };

    _state = _state.copyWith(
      groupCount: clamped,
      players: _buildPlayers(
        mode: _state.mode,
        groupCount: clamped,
        previousPlayers: previousPlayers,
      ),
    );
    notifyListeners();
  }

  void updatePlayerName({required int playerId, required String value}) {
    final trimmedLeft = value.trimLeft();
    final updatedPlayers = _state.players
        .map(
          (player) => player.id == playerId
              ? player.copyWith(name: trimmedLeft)
              : player,
        )
        .toList(growable: false);

    if (trimmedLeft.trim().isNotEmpty) {
      _nameCacheByPlayerId[playerId] = trimmedLeft;
    } else {
      _nameCacheByPlayerId.remove(playerId);
    }

    _state = _state.copyWith(
      players: updatedPlayers,
      showValidationErrors:
          _state.showValidationErrors && !_allNamesValid(updatedPlayers),
    );
    notifyListeners();
  }

  void updatePlayerIdentity({
    required int playerId,
    required ProfileIdentity? identity,
  }) {
    final updatedPlayers = _state.players
        .map(
          (player) => player.id == playerId
              ? player.copyWith(
                  identity: identity,
                  clearIdentity: identity == null,
                )
              : player,
        )
        .toList(growable: false);

    _state = _state.copyWith(players: updatedPlayers);
    notifyListeners();
  }

  void updatePlayerAttraction({
    required int playerId,
    required ProfileAttraction? attraction,
  }) {
    final updatedPlayers = _state.players
        .map(
          (player) => player.id == playerId
              ? player.copyWith(
                  attraction: attraction,
                  clearAttraction: attraction == null,
                )
              : player,
        )
        .toList(growable: false);

    _state = _state.copyWith(players: updatedPlayers);
    notifyListeners();
  }

  void toggleTheme(GameStyleTheme theme) {
    if (_state.themeIsLocked(theme)) {
      return;
    }
    if (theme == GameStyleTheme.cielo) {
      return;
    }

    final enabled = _state.enabledThemes.toSet();
    if (enabled.contains(theme)) {
      enabled.remove(theme);
    } else {
      enabled.add(theme);
    }
    _state = _state.copyWith(enabledThemes: _orderedThemes(enabled));
    notifyListeners();
  }

  void selectTheme(GameStyleTheme theme) {
    toggleTheme(theme);
  }

  void applyPlayerProfile({
    required int playerId,
    required String displayName,
    required ProfileIdentity identity,
    required ProfileAttraction attraction,
  }) {
    final name = displayName.trim();
    final updatedPlayers = _state.players
        .map(
          (player) => player.id == playerId
              ? player.copyWith(
                  name: name,
                  identity: identity,
                  attraction: attraction,
                )
              : player,
        )
        .toList(growable: false);

    if (name.isNotEmpty) {
      _nameCacheByPlayerId[playerId] = name;
    }

    _state = _state.copyWith(
      players: updatedPlayers,
      showValidationErrors:
          _state.showValidationErrors && !_allNamesValid(updatedPlayers),
    );
    notifyListeners();
  }

  void setPremiumAccess(bool isPremium) {
    if (_state.isPremium == isPremium) {
      return;
    }

    final enabledThemes = isPremium
        ? _orderedThemes(_state.enabledThemes)
        : const [GameStyleTheme.cielo];
    _state = _state.copyWith(
      isPremium: isPremium,
      enabledThemes: enabledThemes,
    );
    notifyListeners();
  }

  bool playerHasError(int playerId) {
    if (!_state.showValidationErrors) {
      return false;
    }
    final player = _state.players.firstWhere(
      (candidate) => candidate.id == playerId,
    );
    return player.name.trim().isEmpty;
  }

  GameSetupSubmission? submit() {
    if (!_state.canStart) {
      _state = _state.copyWith(showValidationErrors: true);
      notifyListeners();
      return null;
    }

    _state = _state.copyWith(showValidationErrors: false);
    notifyListeners();

    return GameSetupSubmission(
      mode: _state.mode,
      players: _state.players,
      pairs: _state.mode.isCouples ? _groupByPairs(_state.players) : const [],
      enabledThemes: _state.enabledThemes,
    );
  }

  static List<List<PlayerConfig>> _groupByPairs(List<PlayerConfig> players) {
    final pairs = <List<PlayerConfig>>[];
    for (var index = 0; index < players.length; index += 2) {
      final pair = players.skip(index).take(2).toList(growable: false);
      pairs.add(pair);
    }
    return pairs;
  }

  static bool _allNamesValid(List<PlayerConfig> players) =>
      players.every((player) => player.name.trim().isNotEmpty);
}
