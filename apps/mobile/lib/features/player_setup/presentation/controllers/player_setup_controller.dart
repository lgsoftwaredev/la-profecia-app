import 'package:flutter/foundation.dart';

import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../domain/entities/game_setup_models.dart';

class PlayerSetupController extends ChangeNotifier {
  PlayerSetupController({required GameMode mode, bool isPremium = false})
    : _state = _createInitialState(mode: mode, isPremium: isPremium);

  static GameSetupState _createInitialState({
    required GameMode mode,
    required bool isPremium,
  }) {
    final initialGroupCount = mode.isFriends ? 4 : 1;
    return GameSetupState(
      mode: mode,
      groupCount: initialGroupCount,
      players: _buildPlayers(mode: mode, groupCount: initialGroupCount),
      selectedTheme: GameStyleTheme.cielo,
      isPremium: isPremium,
      showValidationErrors: false,
    );
  }

  static List<PlayerConfig> _buildPlayers({
    required GameMode mode,
    required int groupCount,
    Map<int, String> previousNames = const {},
  }) {
    final totalPlayers = mode.isFriends ? groupCount : groupCount * 2;

    return List<PlayerConfig>.generate(totalPlayers, (index) {
      final id = index + 1;
      return PlayerConfig(
        id: id,
        name: previousNames[id] ?? '',
        pairIndex: mode.isCouples ? index ~/ 2 : null,
      );
    });
  }

  final Map<int, String> _nameCacheByPlayerId = <int, String>{};
  GameSetupState _state;

  GameSetupState get state => _state;
  bool get canIncrement => _state.groupCount < _state.maxGroupCount;
  bool get canDecrement => _state.groupCount > _state.minGroupCount;

  void incrementCount() => _updateGroupCount(_state.groupCount + 1);
  void decrementCount() => _updateGroupCount(_state.groupCount - 1);

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

    _state = _state.copyWith(
      groupCount: clamped,
      players: _buildPlayers(
        mode: _state.mode,
        groupCount: clamped,
        previousNames: _nameCacheByPlayerId,
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

  void selectTheme(GameStyleTheme theme) {
    if (_state.themeIsLocked(theme)) {
      return;
    }
    _state = _state.copyWith(selectedTheme: theme);
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
      selectedTheme: _state.selectedTheme,
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
