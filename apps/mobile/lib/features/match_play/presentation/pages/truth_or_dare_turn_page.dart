import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_3d_pill_button.dart';
import '../../../../core/widgets/premium_slide_button.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../game_mode_selection/presentation/pages/home_page.dart';
import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../../../player_setup/presentation/widgets/round_top_header.dart';
import '../../../premium/presentation/pages/premium_menu_page.dart';
import '../../../premium/presentation/providers/premium_providers.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../domain/entities/active_match_effect.dart';
import '../../domain/entities/game_prompt.dart';
import '../../domain/entities/match_level.dart';
import '../../domain/entities/match_turn.dart';
import '../../domain/entities/truth_or_dare_option.dart';
import '../providers/match_providers.dart';
import '../utils/active_player_name_resolver.dart';
import '../widgets/current_effects_widgets.dart';
import '../widgets/match_timer_chip.dart';
import 'round_score_summary_page.dart';

class TruthOrDareTurnPage extends ConsumerStatefulWidget {
  const TruthOrDareTurnPage({
    required this.submission,
    required this.option,
    this.round = 1,
    this.points = 0,
    this.initialTurn,
    super.key,
  });

  final GameSetupSubmission submission;
  final TruthOrDareOption option;
  final int round;
  final int points;
  final MatchTurn? initialTurn;

  @override
  ConsumerState<TruthOrDareTurnPage> createState() =>
      _TruthOrDareTurnPageState();
}

class _TruthOrDareTurnPageState extends ConsumerState<TruthOrDareTurnPage> {
  var _isResolvingTurn = false;
  var _showPremiumText = false;
  var _showEffectsText = false;
  String? _lastSyncedEffectKey;
  Timer? _timerTicker;
  int? _remainingTimerSeconds;
  String? _timerTurnKey;
  ProviderSubscription<MatchTurn?>? _turnSubscription;

  GameSetupSubmission get _submission =>
      ref.read(activeSetupSubmissionProvider) ?? widget.submission;

  String get _backgroundAsset => _submission.mode.isFriends
      ? 'assets/background-setup-friends-mode.png'
      : 'assets/background-setup-couple-mode.png';

  MatchTurn? get _activeTurn =>
      widget.initialTurn ?? ref.read(matchCurrentTurnProvider);

  bool get _isQuestionTurn {
    final activeTurn = _activeTurn;
    if (activeTurn != null) {
      return activeTurn.promptKind == MatchPromptKind.question;
    }
    return widget.option == TruthOrDareOption.verdad;
  }

  String get _promptText {
    final activeTurn = _activeTurn;
    if (activeTurn != null) {
      return activeTurn.promptText;
    }
    return _isQuestionTurn
        ? 'Describe el momento mas intenso que has vivido.'
        : 'Acepta este reto frente a todos.';
  }

  int? get _timerSeconds => _activeTurn?.timerSeconds;

  int get _round => _activeTurn?.roundNumber ?? widget.round;

  int get _activePlayerId {
    final currentTurn = _activeTurn;
    if (currentTurn != null) {
      return currentTurn.participantId;
    }

    final session = ref.read(matchSessionProvider);
    if (session != null) {
      return session.currentParticipantId;
    }

    return _submission.players.isNotEmpty ? _submission.players.first.id : 1;
  }

  String? get _activePlayerAvatarAsset {
    for (final player in _submission.players) {
      if (player.id == _activePlayerId) {
        return player.avatarAssetPath;
      }
    }
    return null;
  }

  String get _playerName {
    final session = ref.read(matchSessionProvider);
    return resolveActivePlayerName(
      session: session,
      submission: _submission,
      activeParticipantId: _activePlayerId,
      fallback: ActivePlayerNameFallback.turn,
    );
  }

  int get _currentPoints =>
      ref.read(matchScoresProvider)[_activePlayerId] ?? widget.points;

  @override
  void initState() {
    super.initState();
    _turnSubscription = ref.listenManual<MatchTurn?>(matchCurrentTurnProvider, (
      _,
      next,
    ) async {
      _syncTimerForTurn(next);
      await _syncVisibleTurnEffect(next);
    });
    Future<void>(() async {
      _syncTimerForTurn(_activeTurn);
      await _syncVisibleTurnEffect(_activeTurn);
    });
  }

  @override
  void didUpdateWidget(covariant TruthOrDareTurnPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTurn != widget.initialTurn) {
      _syncTimerForTurn(_activeTurn);
    }
  }

  @override
  void dispose() {
    _timerTicker?.cancel();
    _turnSubscription?.close();
    super.dispose();
  }

  void _syncTimerForTurn(MatchTurn? turn) {
    final timerSeconds = turn?.timerSeconds;
    final key = turn == null
        ? 'none'
        : '${turn.turnNumber}:${turn.participantId}:${timerSeconds ?? -1}';
    if (_timerTurnKey == key) {
      return;
    }
    _timerTurnKey = key;
    _timerTicker?.cancel();
    _timerTicker = null;
    _remainingTimerSeconds = timerSeconds;
    if (mounted) {
      setState(() {});
    }
  }

  void _onTimerChipTap() {
    final seconds = _remainingTimerSeconds;
    if (seconds == null || seconds <= 0) {
      return;
    }
    if (_timerTicker != null) {
      _timerTicker?.cancel();
      _timerTicker = null;
      setState(() {});
      return;
    }

    _timerTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final current = _remainingTimerSeconds ?? 0;
      if (current <= 1) {
        timer.cancel();
        _timerTicker = null;
        setState(() {
          _remainingTimerSeconds = 0;
        });
        return;
      }
      setState(() {
        _remainingTimerSeconds = current - 1;
      });
    });
    setState(() {});
  }

  Future<void> _syncVisibleTurnEffect(MatchTurn? turn) async {
    if (turn == null || !turn.hasMatchEffect) {
      return;
    }
    final key = '${turn.turnNumber}:${turn.participantId}';
    if (key == _lastSyncedEffectKey) {
      return;
    }
    _lastSyncedEffectKey = key;
    await ref.read(matchControllerProvider).registerCurrentTurnEffectIfNeeded();
  }

  Future<void> _openSettings() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
  }

  Future<void> _openPremium() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const PremiumMenuPage()));
  }

  Future<void> _onPremiumSlideTap() async {
    if (!_showPremiumText) {
      setState(() {
        _showPremiumText = true;
        _showEffectsText = false;
      });
      return;
    }
    await _openPremium();
  }

  Future<void> _onEffectsSlideTap() async {
    if (!_showEffectsText) {
      setState(() {
        _showEffectsText = true;
        _showPremiumText = false;
      });
      return;
    }
    await _openCurrentEffectsDialog();
  }

  Future<void> _openCurrentEffectsDialog() async {
    final effects = ref.read(matchSessionProvider)?.activeEffects ?? const [];
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.74),
      builder: (_) => CurrentEffectsDialog(effects: effects),
    );
  }

  Future<void> _openRoundScoreSummary({required bool didComplete}) async {
    if (_isResolvingTurn) {
      return;
    }
    setState(() {
      _isResolvingTurn = true;
    });

    if (!didComplete) {
      Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) => _FailedOrHiddenVideoPage(submission: _submission),
        ),
      );
      return;
    }

    final submission = _submission;
    final controller = ref.read(matchControllerProvider);
    final resolution = await controller.resolveCurrentTurn(
      didComplete: didComplete,
    );
    if (!mounted) {
      return;
    }
    if (resolution == null) {
      setState(() {
        _isResolvingTurn = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo registrar el resultado.')),
      );
      return;
    }

    final isFinished = controller.session?.isFinished ?? false;
    final navigator = Navigator.of(context);
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const HomePage(skipActiveMatchDialog: true),
      ),
      (route) => false,
    );
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => RoundScoreSummaryPage(
          submission: submission,
          completedPlayerId: resolution.completedPlayerId,
          scoresByPlayerId: controller.scoresByPlayerId,
          round: resolution.round,
          gainedPoints: resolution.pointsDelta,
          didComplete: didComplete,
          endMatchOnNext: isFinished,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submission =
        ref.watch(activeSetupSubmissionProvider) ?? widget.submission;
    final session = ref.watch(matchSessionProvider);
    final currentTurn =
        widget.initialTurn ?? ref.watch(matchCurrentTurnProvider);
    final scoresByPlayerId = ref.watch(matchScoresProvider);
    final pendingLevel = ref.watch(matchPendingLevelProvider);
    final isPremium = ref.watch(premiumAccessProvider);
    final level =
        currentTurn?.level ??
        pendingLevel ??
        submission.preferredTheme.toMatchLevel;
    final palette = _TurnVisualPalette.forLevel(level);
    final isQuestion = currentTurn == null
        ? widget.option == TruthOrDareOption.verdad
        : currentTurn.promptKind == MatchPromptKind.question;
    final promptText = currentTurn?.promptText ?? _promptText;
    final timerSeconds =
        _remainingTimerSeconds ??
        currentTurn?.timerSeconds ??
        _timerSeconds ??
        10;
    final round = currentTurn?.roundNumber ?? _round;
    final effects = session?.activeEffects ?? const <ActiveMatchEffect>[];
    final activePlayerId = currentTurn?.participantId ?? _activePlayerId;
    final currentPoints = scoresByPlayerId[activePlayerId] ?? _currentPoints;
    final playerName = _playerName;
    final playerAvatar = _activePlayerAvatarAsset;

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_backgroundAsset, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0x7304020D),
                  const Color(0xFF05020E).withValues(alpha: 0.96),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.02),
                radius: 1.0,
                colors: [
                  palette.accent.withValues(alpha: 0.42),
                  palette.accent.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
                stops: const [0, 0.40, 0.86],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  RoundTopHeader(
                    round: round,
                    isFriendsMode: submission.mode.isFriends,
                    onBackTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    onSettingsTap: _openSettings,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 164),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.xxl * 1.5),
                          _PlayerHeader(
                            name: playerName,
                            points: currentPoints,
                            accent: palette.accent,
                            avatarAsset: playerAvatar,
                          ),
                          const SizedBox(height: AppSpacing.xxl * 1.5),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 33.0,
                            ),
                            child: _TurnPromptCard(
                              level: level,
                              palette: palette,
                              isQuestion: isQuestion,
                              promptText: promptText,
                              playerName: playerName,
                              timerSeconds: timerSeconds,
                              onTimerTap: _onTimerChipTap,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl * 1.5),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 3.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _TurnActionButton(
                                    label: isQuestion
                                        ? 'Confesado'
                                        : 'Completado',
                                    iconAsset: isQuestion
                                        ? 'assets/logo-icon-turn-checked.png'
                                        : 'assets/logo-icon-premium-corona.png',
                                    gradientStart: isQuestion
                                        ? const Color(0xFF2B7D2F)
                                        : const Color(0xFF766032),
                                    gradientEnd: isQuestion
                                        ? const Color(0xFF204F24)
                                        : const Color(0xFF4F4128),
                                    glowColor: isQuestion
                                        ? const Color(0xFF42E053)
                                        : const Color(0xFFFBC34B),
                                    isLoading: _isResolvingTurn,
                                    onTap: _isResolvingTurn
                                        ? null
                                        : () => _openRoundScoreSummary(
                                            didComplete: true,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: _TurnActionButton(
                                    label: isQuestion ? 'Ocultado' : 'Fallado',
                                    iconAsset: isQuestion
                                        ? 'assets/logo-icon-turn-locked.png'
                                        : 'assets/logo-icon-cancel.png',
                                    gradientStart: const Color(0xFF512127),
                                    gradientEnd: const Color(0xFF2E1015),
                                    glowColor: const Color(0xFFE84A4A),
                                    isLoading: _isResolvingTurn,
                                    onTap: _isResolvingTurn
                                        ? null
                                        : () => _openRoundScoreSummary(
                                            didComplete: false,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isPremium)
            Positioned(
              top: 182,
              right: -4,
              child: TapRegion(
                onTapOutside: (_) {
                  if (_showPremiumText) {
                    setState(() {
                      _showPremiumText = false;
                    });
                  }
                },
                child: PremiumSlideButton(
                  expanded: _showPremiumText,
                  isPremium: false,
                  onTap: _onPremiumSlideTap,
                ),
              ),
            ),
          if (isPremium)
            Positioned(
              top: 182,
              right: -4,
              child: TapRegion(
                onTapOutside: (_) {
                  if (_showEffectsText) {
                    setState(() {
                      _showEffectsText = false;
                    });
                  }
                },
                child: CurrentEffectsSlideButton(
                  expanded: _showEffectsText,
                  hasEffects: effects.isNotEmpty,
                  onTap: _onEffectsSlideTap,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({
    required this.name,
    required this.points,
    required this.accent,
    required this.avatarAsset,
  });

  final String name;
  final int points;
  final Color accent;
  final String? avatarAsset;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarAsset != null && avatarAsset!.isNotEmpty;
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.42),
                blurRadius: 22,
                spreadRadius: 1.2,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.34),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
          ),
          child: ClipOval(
            child: hasAvatar
                ? Image.asset(avatarAsset!, fit: BoxFit.cover)
                : DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          accent,
                          Color.lerp(accent, Colors.black, 0.7)!,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        _PointsChip(points: points),
      ],
    );
  }
}

class _TurnPromptCard extends StatelessWidget {
  const _TurnPromptCard({
    required this.level,
    required this.palette,
    required this.isQuestion,
    required this.promptText,
    required this.playerName,
    required this.timerSeconds,
    this.onTimerTap,
  });

  final MatchLevel level;
  final _TurnVisualPalette palette;
  final bool isQuestion;
  final String promptText;
  final String playerName;
  final int? timerSeconds;
  final VoidCallback? onTimerTap;

  @override
  Widget build(BuildContext context) {
    final title = isQuestion ? 'PREGUNTA' : 'RETO';
    final isInframundo = level == MatchLevel.inframundo;
    final iconAsset = isQuestion
        ? (isInframundo
              ? 'assets/logo-icon-turn-question-inframundo.png'
              : 'assets/logo-icon-turn-question.png')
        : (isInframundo
              ? 'assets/logo-icon-turn-challenge-inframundo.png'
              : 'assets/logo-icon-turn-challenge.png');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 58, 24, 44),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                palette.surfaceTop.withValues(alpha: isQuestion ? 1 : 0.00),
                palette.surfaceBottom.withValues(alpha: isQuestion ? 1 : 0),
              ],
            ),
            border: Border.all(
              color: palette.accent.withValues(alpha: 0.60),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: palette.accent.withValues(alpha: 0.28),
                blurRadius: 34,
                spreadRadius: 1.2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.46),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Image.asset(
                iconAsset,
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.94),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _PromptBubble(
                text: promptText,
                playerName: playerName,
                highlightColor: palette.accent,
                isChallenge: !isQuestion,
              ),
            ],
          ),
        ),
        Positioned(
          top: -18,
          left: 0,
          right: 0,
          child: Center(
            child: _LevelChip(level: level, accent: palette.accent),
          ),
        ),
        if (timerSeconds != null)
          Positioned(
            bottom: -14,
            left: 0,
            right: 0,
            child: Center(
              child: MatchTimerChip(
                seconds: timerSeconds!,
                accent: palette.accent,
                onTap: onTimerTap,
              ),
            ),
          ),
      ],
    );
  }
}

class _PromptBubble extends StatelessWidget {
  const _PromptBubble({
    required this.text,
    required this.playerName,
    required this.highlightColor,
    required this.isChallenge,
  });

  final String text;
  final String playerName;
  final Color highlightColor;
  final bool isChallenge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(
              0xFF1A212D,
            ).withValues(alpha: isChallenge ? 0.84 : 0.70),
            const Color(
              0xFF05070C,
            ).withValues(alpha: isChallenge ? 0.98 : 0.90),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: isChallenge ? 0.16 : 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.38),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text.rich(
        _highlightPlayerName(
          source: text,
          playerName: playerName,
          baseStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.93),
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            fontSize: 19,
            height: 1.16,
          ),
          highlightStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: highlightColor,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            fontSize: 19,
            height: 1.16,
          ),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TextSpan _highlightPlayerName({
    required String source,
    required String playerName,
    TextStyle? baseStyle,
    TextStyle? highlightStyle,
  }) {
    final normalizedPlayer = playerName.trim();
    if (normalizedPlayer.isEmpty) {
      return TextSpan(text: source, style: baseStyle);
    }

    final lowerText = source.toLowerCase();
    final lowerPlayer = normalizedPlayer.toLowerCase();
    final start = lowerText.indexOf(lowerPlayer);
    if (start < 0) {
      return TextSpan(text: source, style: baseStyle);
    }
    final end = start + normalizedPlayer.length;
    final before = source.substring(0, start);
    final highlighted = source.substring(start, end);
    final after = source.substring(end);

    return TextSpan(
      style: baseStyle,
      children: [
        TextSpan(text: before),
        TextSpan(text: highlighted, style: highlightStyle),
        TextSpan(text: after),
      ],
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level, required this.accent});

  final MatchLevel level;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final (iconAsset, label) = switch (level) {
      MatchLevel.cielo => ('assets/cielo-icon-logo.png', 'Cielo'),
      MatchLevel.tierra => ('assets/tierra-icon-logo.png', 'Tierra'),
      MatchLevel.infierno => ('assets/infierno-icon-logo.png', 'Infierno'),
      MatchLevel.inframundo => (
        'assets/inframundo-icon-logo.png',
        'Inframundo',
      ),
    };

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF072016).withValues(alpha: 0.96),
            const Color(0xFF04110C).withValues(alpha: 0.96),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.30),
            blurRadius: 16,
            spreadRadius: 0.8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconAsset, width: 22, height: 22, fit: BoxFit.contain),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w500,
              fontSize: 28 * 0.56,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsChip extends StatelessWidget {
  const _PointsChip({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFF15131D).withValues(alpha: 0.78),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/logo-icon-start-points.png',
            width: 22,
            height: 22,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$points puntos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
              fontWeight: FontWeight.w500,
              fontSize: 24 * 0.58,
            ),
          ),
        ],
      ),
    );
  }
}

class _TurnActionButton extends StatelessWidget {
  const _TurnActionButton({
    required this.label,
    required this.iconAsset,
    required this.gradientStart,
    required this.gradientEnd,
    required this.glowColor,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final Color gradientStart;
  final Color gradientEnd;
  final Color glowColor;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderTop = Color.lerp(glowColor, Colors.white, 0.30)!;
    final borderBottom = Color.lerp(glowColor, Colors.black, 0.52)!;
    final borderRadius = BorderRadius.circular(24);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            borderTop.withValues(alpha: 0.96),
            borderBottom.withValues(alpha: 0.88),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.40),
            blurRadius: 7,
            spreadRadius: 0.0,
            offset: const Offset(-5, 0),
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.40),
            blurRadius: 7,
            spreadRadius: 0.8,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.30),
            blurRadius: 7,
            spreadRadius: 1.0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.35),
        child: Stack(
          children: [
            App3dPillButton(
              label: '',
              color: Color.lerp(glowColor, Colors.black, 0.70)!,
              gradientColors: [
                const Color(0xB0060606),
                const Color(0xB0060606),
              ],
              height: 62,
              depth: 3.6,
              borderRadius: 22,
              isLoading: isLoading,
              onTap: onTap,
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.44,

                        colors: [
                          Color.lerp(
                            glowColor,
                            Colors.white,
                            0.15,
                          )!.withValues(alpha: 0.42),
                          glowColor.withValues(alpha: 0.26),
                          const Color.fromARGB(51, 0, 0, 0),
                        ],
                        stops: const [0.0, 0.44, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.22),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.22),
                        ],
                        stops: const [0.0, 0.24, 0.86, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!isLoading)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          iconAsset,
                          width: 33,
                          height: 33,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 35 * 0.56,
                                shadows: const [
                                  Shadow(
                                    color: Color(0xC0000000),
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TurnVisualPalette {
  const _TurnVisualPalette({
    required this.accent,
    required this.surfaceTop,
    required this.surfaceBottom,
  });

  final Color accent;
  final Color surfaceTop;
  final Color surfaceBottom;

  static _TurnVisualPalette forLevel(MatchLevel level) {
    return switch (level) {
      MatchLevel.cielo => const _TurnVisualPalette(
        accent: Color(0xFF3FAEFF),
        surfaceTop: Color(0xAA1D4D81),
        surfaceBottom: Color(0xA313365E),
      ),
      MatchLevel.tierra => const _TurnVisualPalette(
        accent: Color(0xFF47C84F),
        surfaceTop: Color(0x9A1A4D20),
        surfaceBottom: Color(0x99123517),
      ),
      MatchLevel.infierno => const _TurnVisualPalette(
        accent: Color(0xFFFF7043),
        surfaceTop: Color(0xA9632418),
        surfaceBottom: Color(0xA53B160F),
      ),
      MatchLevel.inframundo => const _TurnVisualPalette(
        accent: Color(0xFFB76CFF),
        surfaceTop: Color(0xA743205F),
        surfaceBottom: Color(0xA8251439),
      ),
    };
  }
}

class _FailedOrHiddenVideoPage extends ConsumerStatefulWidget {
  const _FailedOrHiddenVideoPage({required this.submission});

  final GameSetupSubmission submission;

  @override
  ConsumerState<_FailedOrHiddenVideoPage> createState() =>
      _FailedOrHiddenVideoPageState();
}

class _FailedOrHiddenVideoPageState
    extends ConsumerState<_FailedOrHiddenVideoPage> {
  VideoPlayerController? _controller;
  var _didScheduleClose = false;
  var _isResolving = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final controller = VideoPlayerController.asset(
      'assets/videos/video-fallado-ocultado.mp4',
    );
    _controller = controller;
    controller.addListener(_handleVideoProgress);
    try {
      await controller.initialize();
      await controller.setLooping(false);
      await controller.play();
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      _scheduleClose();
    }
  }

  void _handleVideoProgress() {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _didScheduleClose) {
      return;
    }
    final duration = controller.value.duration;
    final position = controller.value.position;
    if (duration > Duration.zero && position >= duration) {
      _scheduleClose();
    }
  }

  void _scheduleClose() {
    if (_didScheduleClose) {
      return;
    }
    _didScheduleClose = true;
    _resolveAndGoNext();
  }

  Future<void> _resolveAndGoNext() async {
    if (!mounted || _isResolving) {
      return;
    }
    _isResolving = true;
    final controller = ref.read(matchControllerProvider);
    final resolution = await controller.resolveCurrentTurn(didComplete: false);
    if (!mounted) {
      return;
    }
    if (resolution == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo registrar el resultado.')),
      );
      _isResolving = false;
      return;
    }

    final isFinished = controller.session?.isFinished ?? false;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => RoundScoreSummaryPage(
          submission: widget.submission,
          completedPlayerId: resolution.completedPlayerId,
          scoresByPlayerId: controller.scoresByPlayerId,
          round: resolution.round,
          gainedPoints: resolution.pointsDelta,
          didComplete: false,
          endMatchOnNext: isFinished,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleVideoProgress);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: controller == null || !controller.value.isInitialized
            ? const SizedBox.expand(child: ColoredBox(color: Colors.black))
            : SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
      ),
    );
  }
}
