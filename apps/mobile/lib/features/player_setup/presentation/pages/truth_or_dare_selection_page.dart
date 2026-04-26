import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../match_play/domain/entities/game_prompt.dart';
import '../../../game_mode_selection/presentation/pages/home_page.dart';
import '../../../match_play/presentation/providers/match_providers.dart';
import '../../../match_play/domain/entities/truth_or_dare_option.dart';
import '../../../match_play/presentation/pages/final_judgment_page.dart';
import '../../../match_play/presentation/pages/truth_or_dare_turn_page.dart';
import '../../../match_play/presentation/utils/active_player_name_resolver.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../domain/entities/game_setup_models.dart';
import '../widgets/level_card_frame.dart';
import '../widgets/round_top_header.dart';

class TruthOrDareSelectionPage extends ConsumerStatefulWidget {
  const TruthOrDareSelectionPage({
    required this.submission,
    required this.selectedTheme,
    super.key,
  });

  final GameSetupSubmission submission;
  final GameStyleTheme selectedTheme;

  @override
  ConsumerState<TruthOrDareSelectionPage> createState() =>
      _TruthOrDareSelectionPageState();
}

class _TruthOrDareSelectionPageState
    extends ConsumerState<TruthOrDareSelectionPage> {
  TruthOrDareOption? _selectedOption;

  PlayerConfig? _activePlayerConfig({
    required GameSetupSubmission submission,
    required int? currentParticipantId,
  }) {
    if (submission.players.isEmpty) {
      return null;
    }
    if (currentParticipantId == null) {
      return submission.players.first;
    }
    for (final player in submission.players) {
      if (player.id == currentParticipantId) {
        return player;
      }
    }
    return submission.players.first;
  }

  String _themeLabel(GameStyleTheme theme) {
    final uppercase = theme.label;
    return '${uppercase.substring(0, 1)}${uppercase.substring(1).toLowerCase()}';
  }

  int _playerPoints(int? currentParticipantId, Map<int, int> scoresByPlayerId) {
    if (currentParticipantId == null) {
      return 0;
    }
    return scoresByPlayerId[currentParticipantId] ?? 0;
  }

  Future<void> _openTurnPage(TruthOrDareOption option) async {
    final submission =
        ref.read(activeSetupSubmissionProvider) ?? widget.submission;
    ref.read(activeSetupSubmissionProvider.notifier).state = submission;

    final kind = option == TruthOrDareOption.verdad
        ? MatchPromptKind.question
        : MatchPromptKind.challenge;
    final controller = ref.read(matchControllerProvider);
    final preferredLevel = widget.selectedTheme.toMatchLevel;
    final availableLevels = controller.availableLevels;
    final selectedLevel = availableLevels.contains(preferredLevel)
        ? preferredLevel
        : availableLevels.isNotEmpty
        ? availableLevels.first
        : preferredLevel;
    final turn = await controller.startTurn(
      kind: kind,
      preferredLevel: selectedLevel,
      forceNewTurnWhenPending: true,
    );
    if (!mounted) {
      return;
    }
    if (turn == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo iniciar el turno.')),
      );
      return;
    }

    final points = ref.read(matchScoresProvider)[turn.participantId] ?? 0;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TruthOrDareTurnPage(
          submission: submission,
          option: option,
          round: turn.roundNumber,
          points: points,
          initialTurn: turn,
        ),
      ),
    );
  }

  Future<void> _finishMatch() async {
    final submission =
        ref.read(activeSetupSubmissionProvider) ?? widget.submission;
    final result = await ref
        .read(matchControllerProvider)
        .finishMatchManually();
    if (!mounted || result == null) {
      return;
    }
    final navigator = Navigator.of(context);
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const HomePage(skipActiveMatchDialog: true),
      ),
      (route) => false,
    );
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => FinalJudgmentPage(
          submission: submission,
          scoresByPlayerId: result.scoresByPlayerId,
        ),
      ),
    );
  }

  Future<void> _handleCloseAttempt({required bool hasAnyPoints}) async {
    if (!hasAnyPoints) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }

    final decision = await showDialog<_FinalizeDecision>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Finalizar partida'),
          content: const Text(
            'Hay jugadores con puntos. Quieres finalizar la partida?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(_FinalizeDecision.keep),
              child: const Text('Continuar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_FinalizeDecision.finish),
              child: const Text('Finalizar'),
            ),
          ],
        );
      },
    );

    if (!mounted || decision != _FinalizeDecision.finish) {
      return;
    }
    await _finishMatch();
  }

  Future<void> _openSettings() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    final submission =
        ref.watch(activeSetupSubmissionProvider) ?? widget.submission;
    final session = ref.watch(matchSessionProvider);
    final activeSession = session != null && !session.isFinished
        ? session
        : null;
    final scoresByPlayerId = ref.watch(matchScoresProvider);
    final hasAnyPoints =
        activeSession != null &&
        scoresByPlayerId.values.any((score) => score != 0);
    final currentParticipantId = activeSession?.currentParticipantId;
    final currentRound = activeSession?.roundNumber ?? 1;
    final selectedTheme = widget.selectedTheme;
    final isInframundoTheme = selectedTheme == GameStyleTheme.inframundo;
    final themeAccent = selectedTheme.accentColor;
    final activePlayer = _activePlayerConfig(
      submission: submission,
      currentParticipantId: currentParticipantId,
    );
    final currentPlayerName = resolveActivePlayerName(
      session: activeSession,
      submission: submission,
      activeParticipantId: currentParticipantId,
      fallback: ActivePlayerNameFallback.selection,
    );
    final backgroundAsset = submission.mode.isFriends
        ? 'assets/background-setup-friends-mode.png'
        : 'assets/background-setup-couple-mode.png';
    final screenHeight = MediaQuery.of(context).size.height;
    final triangleHeight = (screenHeight * 0.42).clamp(280.0, 430.0);
    final trueWidth = triangleHeight * (318 / 894);
    final challengeWidth = triangleHeight * (320 / 894);
    const glowBlue = Color(0xFF23A2FF);
    const glowPink = Color(0xFFFF4DA2);

    return PopScope(
      canPop: !hasAnyPoints,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && hasAnyPoints) {
          _handleCloseAttempt(hasAnyPoints: hasAnyPoints);
        }
      },
      child: Scaffold(
        extendBody: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(backgroundAsset, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0x34040213),
                    const Color(0xFF06020F).withValues(alpha: 0.86),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.24),
                  radius: 0.9,
                  colors: [
                    themeAccent.withValues(alpha: 0.34),
                    themeAccent.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.34, 0.84],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0.75),
                  radius: 1.02,
                  colors: [
                    Color.lerp(
                      themeAccent,
                      Colors.black,
                      0.32,
                    )!.withValues(alpha: 0.24),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.62],
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
                      round: currentRound,
                      isFriendsMode: submission.mode.isFriends,
                      onBackTap: () =>
                          _handleCloseAttempt(hasAnyPoints: hasAnyPoints),
                      onSettingsTap: _openSettings,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 170),
                        child: Column(
                          children: [
                            const SizedBox(height: AppSpacing.xxl * 1.5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xxl * 1.5,
                              ),
                              child: _PlayerSummary(
                                playerName: currentPlayerName,
                                avatarAssetPath: activePlayer?.avatarAssetPath,
                                accent: themeAccent,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _PointsChip(
                              points: _playerPoints(
                                currentParticipantId,
                                scoresByPlayerId,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            SizedBox(
                              height: triangleHeight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: trueWidth,
                                    child: _SelectableTriangleButton(
                                      label: 'Verdad',
                                      assetPath:
                                          'assets/button-select-true.png',
                                      isSelected:
                                          _selectedOption ==
                                          TruthOrDareOption.verdad,
                                      rotationY: 0.12,
                                      glowColor: glowBlue,
                                      onTap: () {
                                        setState(() {
                                          _selectedOption =
                                              TruthOrDareOption.verdad;
                                        });
                                        ref
                                                .read(
                                                  activeSetupSubmissionProvider
                                                      .notifier,
                                                )
                                                .state =
                                            submission;
                                        _openTurnPage(TruthOrDareOption.verdad);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xxl * 1.7),
                                  SizedBox(
                                    width: challengeWidth,
                                    child: _SelectableTriangleButton(
                                      label: 'Reto',
                                      assetPath: isInframundoTheme
                                          ? 'assets/button-select-challenge-inframundo.png'
                                          : 'assets/button-select-challenge.png',
                                      isSelected:
                                          _selectedOption ==
                                          TruthOrDareOption.reto,
                                      rotationY: -0.12,
                                      glowColor: glowPink,
                                      onTap: () {
                                        setState(() {
                                          _selectedOption =
                                              TruthOrDareOption.reto;
                                        });
                                        ref
                                                .read(
                                                  activeSetupSubmissionProvider
                                                      .notifier,
                                                )
                                                .state =
                                            submission;
                                        _openTurnPage(TruthOrDareOption.reto);
                                      },
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
            if (isInframundoTheme)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/background-bottom-inframundo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Positioned(
              top: 154,
              left: -10,
              child: _ThemeLevelSideBadge(
                theme: selectedTheme,
                label: _themeLabel(selectedTheme),
                accent: themeAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _FinalizeDecision { keep, finish }

class _PointsChip extends StatelessWidget {
  const _PointsChip({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFF15131D).withValues(alpha: 0.84),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
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
              fontSize: 22 * 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectableTriangleButton extends StatefulWidget {
  const _SelectableTriangleButton({
    required this.label,
    required this.assetPath,
    required this.isSelected,
    required this.rotationY,
    required this.glowColor,
    required this.onTap,
  });

  final String label;
  final String assetPath;
  final bool isSelected;
  final double rotationY;
  final Color glowColor;
  final VoidCallback onTap;

  @override
  State<_SelectableTriangleButton> createState() =>
      _SelectableTriangleButtonState();
}

class _SelectableTriangleButtonState extends State<_SelectableTriangleButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: widget.label,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          offset: Offset(0, _pressed ? 0.092 : 0.1),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOut,
            scale: _pressed
                ? 0.99
                : widget.isSelected
                ? 1.02
                : 1.2,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.00135)
                    ..rotateY(widget.rotationY),
                  child: DecoratedBox(
                    decoration: BoxDecoration(boxShadow: []),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.white.withValues(
                          alpha: widget.isSelected ? 1 : 0.96,
                        ),
                        BlendMode.modulate,
                      ),
                      child: Image.asset(
                        widget.assetPath,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeLevelSideBadge extends StatelessWidget {
  const _ThemeLevelSideBadge({
    required this.theme,
    required this.label,
    required this.accent,
  });

  final GameStyleTheme theme;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 86,
      child: IgnorePointer(
        child: VerticalLevelCardFrame(
          onTap: () {},
          enabled: false,
          width: 62,
          borderRadius: 14,
          borderThickness: 1.1,
          borderColor: Color.lerp(
            accent,
            const Color(0xCCBB7605),
            0.36,
          )!.withValues(alpha: 0.94),
          baseTopColor: const Color(0xFF2A1C22).withValues(alpha: 0.96),
          baseBottomColor: const Color(0xFF1A1016).withValues(alpha: 0.96),
          bottomTintStrong: accent.withValues(alpha: 0.22),
          bottomTintSoft: accent.withValues(alpha: 0.09),
          topLineColor: accent.withValues(alpha: 0.26),
          topShadowStrongAlpha: 0.42,
          topShadowSoftAlpha: 0.20,
          glowColor: accent.withValues(alpha: 0.28),
          contentPadding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.xxs,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                theme.iconAsset,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerSummary extends StatelessWidget {
  const _PlayerSummary({
    required this.playerName,
    required this.avatarAssetPath,
    required this.accent,
  });

  final String playerName;
  final String? avatarAssetPath;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarAssetPath != null && avatarAssetPath!.isNotEmpty;
    return Column(
      children: [
        Container(
          width: 62,
          height: 62,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: accent.withValues(alpha: 0.75),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.35),
                blurRadius: 18,
                spreadRadius: 0.4,
              ),
            ],
          ),
          child: ClipOval(
            child: hasAvatar
                ? Image.asset(avatarAssetPath!, fit: BoxFit.cover)
                : DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          accent.withValues(alpha: 0.9),
                          Color.lerp(accent, Colors.black, 0.6)!,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          playerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
        ),
      ],
    );
  }
}
