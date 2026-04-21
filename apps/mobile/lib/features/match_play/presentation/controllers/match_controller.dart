import 'package:flutter/foundation.dart';

import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../../../profile/domain/entities/user_stats_summary.dart';
import '../../../premium/domain/services/entitlement_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/game_prompt.dart';
import '../../domain/entities/match_level.dart';
import '../../domain/entities/match_result.dart';
import '../../domain/entities/match_session.dart';
import '../../domain/entities/match_turn.dart';
import '../../domain/repositories/active_match_repository.dart';
import '../../domain/repositories/couples_content_repository.dart';
import '../../domain/repositories/friends_content_repository.dart';
import '../../domain/repositories/game_history_repository.dart';
import '../../domain/services/game_engine.dart';

class MatchController extends ChangeNotifier {
  MatchController({
    required GameEngine engine,
    required ActiveMatchRepository activeMatchRepository,
    required FriendsContentRepository friendsContentRepository,
    required CouplesContentRepository couplesContentRepository,
    required GameHistoryRepository historyRepository,
    required EntitlementService entitlementService,
    required AnalyticsService analyticsService,
  }) : _engine = engine,
       _activeMatchRepository = activeMatchRepository,
       _friendsContentRepository = friendsContentRepository,
       _couplesContentRepository = couplesContentRepository,
       _historyRepository = historyRepository,
       _entitlementService = entitlementService,
       _analyticsService = analyticsService;

  final GameEngine _engine;
  final ActiveMatchRepository _activeMatchRepository;
  final FriendsContentRepository _friendsContentRepository;
  final CouplesContentRepository _couplesContentRepository;
  final GameHistoryRepository _historyRepository;
  final EntitlementService _entitlementService;
  final AnalyticsService _analyticsService;

  MatchSession? _session;
  MatchFinalResult? _finalResult;
  bool _loading = false;
  String? _error;

  MatchSession? get session => _session;
  MatchFinalResult? get finalResult => _finalResult;
  bool get isLoading => _loading;
  String? get error => _error;

  bool get hasActiveMatch => _session != null && !_session!.isFinished;

  MatchTurn? get currentTurn => _session?.pendingTurn;

  Map<int, int> get scoresByPlayerId =>
      _session?.scoresByParticipantId ?? const <int, int>{};

  MatchLevel? get pendingLevel => _session?.pendingTurn?.level;

  GameSetupSubmission? get activeSetupSubmission {
    final current = _session;
    if (current == null) {
      return null;
    }

    final players = current.participants
        .map(
          (participant) => PlayerConfig(
            id: participant.id,
            name: participant.name,
            pairIndex: participant.pairIndex,
            authUserId: participant.authUserId,
            isAuthenticatedUser: participant.isAuthenticatedUser,
          ),
        )
        .toList(growable: false);

    return GameSetupSubmission(
      mode: current.mode,
      players: players,
      pairs: current.mode.isCouples
          ? _groupByPairs(players)
          : const <List<PlayerConfig>>[],
      selectedTheme:
          (current.pendingTurn?.level ?? MatchLevel.cielo).toGameStyleTheme,
    );
  }

  List<MatchLevel> get availableLevels {
    final current = _session;
    if (current == null) {
      return _engine.availableLevels(
        completedRounds: 0,
        hasPremium: _entitlementService.hasPremiumAccess(),
      );
    }

    return _engine.availableLevels(
      completedRounds: current.completedRounds,
      hasPremium: _entitlementService.hasPremiumAccess(),
    );
  }

  Future<void> restoreActiveMatch() async {
    _setLoading(true);
    try {
      _session = await _activeMatchRepository.loadActive();
      _finalResult = null;
      _error = null;
    } catch (_) {
      _error = 'No se pudo restaurar la partida local.';
    }
    _setLoading(false);
  }

  Future<void> createMatch(GameSetupSubmission setup) async {
    _setLoading(true);
    _error = null;

    try {
      _session = _engine.createMatch(setup: setup);
      _finalResult = null;
      _session = await _activeMatchRepository.save(_session!);
      await _analyticsService.logGameStarted(
        mode: setup.mode.name,
        playersCount: setup.players.length,
        startingLevel: setup.selectedTheme.toMatchLevel.name,
      );
    } catch (_) {
      _error = 'No se pudo crear la partida.';
    }

    _setLoading(false);
  }

  Future<MatchTurn?> startTurn({
    required MatchPromptKind kind,
    MatchLevel? preferredLevel,
    bool randomLevel = false,
    bool forceNewTurnWhenPending = false,
  }) async {
    final current = _session;
    if (current == null || current.isFinished) {
      return null;
    }

    final baseSession = forceNewTurnWhenPending && current.pendingTurn != null
        ? current.copyWith(clearPendingTurn: true)
        : current;

    if (baseSession.pendingTurn != null) {
      return baseSession.pendingTurn;
    }

    _setLoading(true);
    try {
      await _entitlementService.refreshPremiumAccess();
      final selectedLevel = _engine.resolveLevel(
        session: baseSession,
        hasPremium: _entitlementService.hasPremiumAccess(),
        preferred: preferredLevel,
        randomSelection: randomLevel,
      );

      final prompt = current.mode.isFriends
          ? await _friendsContentRepository.pickPrompt(
              level: selectedLevel,
              kind: kind,
            )
          : await _couplesContentRepository.pickPrompt(
              level: selectedLevel,
              kind: kind,
            );

      _session = _engine.createTurn(
        session: baseSession,
        promptKind: kind,
        level: selectedLevel,
        prompt: prompt,
      );

      _session = await _activeMatchRepository.save(_session!);
      _error = null;
      _setLoading(false);
      return _session!.pendingTurn;
    } catch (_) {
      _error = 'No se pudo preparar el turno.';
      _setLoading(false);
      return null;
    }
  }

  Future<MatchTurnResolution?> resolveCurrentTurn({
    required bool didComplete,
  }) async {
    final current = _session;
    if (current == null || current.pendingTurn == null) {
      return null;
    }

    _setLoading(true);
    try {
      final pendingTurn = current.pendingTurn;
      if (pendingTurn == null) {
        _setLoading(false);
        return null;
      }
      final resolution = _engine.resolveTurn(
        session: current,
        didComplete: didComplete,
      );

      _session = resolution.session;
      _error = null;

      if (_session!.isFinished) {
        _finalResult = _engine.buildFinalResult(_session!);
        await _activeMatchRepository.persistFinalResult(
          session: _session!,
          result: _finalResult!,
        );
        await _persistFinalStats(_session!, _finalResult!);
        await _activeMatchRepository.clear();
      } else {
        _session = await _activeMatchRepository.save(_session!);
      }

      _setLoading(false);
      await _analyticsService.logRoundCompleted(
        round: resolution.round,
        didComplete: didComplete,
        level: pendingTurn.level.name,
        promptType: pendingTurn.promptKind.name,
      );
      return resolution;
    } catch (_) {
      _error = 'No se pudo registrar el resultado del turno.';
      _setLoading(false);
      return null;
    }
  }

  Future<MatchFinalResult?> finishMatchManually() async {
    final current = _session;
    if (current == null) {
      return null;
    }

    _setLoading(true);
    try {
      _session = _engine.finishMatch(current);
      _session = await _activeMatchRepository.save(_session!);
      _finalResult = _engine.buildFinalResult(_session!);
      await _activeMatchRepository.persistFinalResult(
        session: _session!,
        result: _finalResult!,
      );
      await _persistFinalStats(_session!, _finalResult!);
      await _activeMatchRepository.clear();
      _error = null;
      _setLoading(false);
      return _finalResult;
    } catch (_) {
      _error = 'No se pudo finalizar la partida.';
      _setLoading(false);
      return null;
    }
  }

  Future<void> discardActiveMatch() async {
    _session = null;
    _finalResult = null;
    _error = null;
    await _activeMatchRepository.clear();
    notifyListeners();
  }

  Future<void> _persistFinalStats(
    MatchSession finished,
    MatchFinalResult result,
  ) async {
    final authenticatedParticipant = finished.authenticatedParticipant;
    if (authenticatedParticipant == null) {
      return;
    }

    final participantScore = authenticatedParticipant.score;
    final won = switch (result.winnerKind) {
      MatchWinnerKind.player =>
        result.winnerPlayer?.id == authenticatedParticipant.id,
      MatchWinnerKind.pair =>
        authenticatedParticipant.pairIndex != null &&
            result.winnerPairIndex == authenticatedParticipant.pairIndex,
    };
    final scoreDelta = won ? participantScore : -participantScore;

    await _historyRepository.registerFinishedMatch(
      sessionId: finished.remoteSessionId ?? finished.id,
      playedAt: finished.endedAt ?? DateTime.now(),
      resultLabel: won ? 'Ganada' : 'Perdida',
      scoreDelta: scoreDelta,
      won: won,
    );
  }

  Future<UserStatsSummary> readSummary() => _historyRepository.readSummary();

  Future<bool> saveFinalGroupPenalty(String text) async {
    final normalizedText = text.trim();
    final current = _session;
    if (normalizedText.isEmpty || current == null) {
      return false;
    }
    if (current.remoteSessionId == null) {
      return false;
    }

    try {
      await _activeMatchRepository.persistFinalPenalty(
        session: current,
        penaltyText: normalizedText,
      );
      return true;
    } catch (ex) {
      debugPrint('saveFinalGroupPenalty error: $ex');
      debugPrint(ex.toString());
      return false;
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  List<List<PlayerConfig>> _groupByPairs(List<PlayerConfig> players) {
    final pairs = <List<PlayerConfig>>[];
    for (var i = 0; i < players.length; i += 2) {
      pairs.add(players.skip(i).take(2).toList(growable: false));
    }
    return pairs;
  }
}
