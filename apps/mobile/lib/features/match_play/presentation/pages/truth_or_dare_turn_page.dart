import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_3d_pill_button.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../game_mode_selection/presentation/pages/home_page.dart';
import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../providers/match_providers.dart';
import '../utils/active_player_name_resolver.dart';
import '../../domain/entities/truth_or_dare_option.dart';
import '../../domain/entities/match_turn.dart';
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

  GameSetupSubmission get _submission =>
      ref.read(activeSetupSubmissionProvider) ?? widget.submission;

  String get _backgroundAsset => _submission.mode.isFriends
      ? 'assets/background-setup-friends-mode.png'
      : 'assets/background-setup-couple-mode.png';

  Color get _modeAccent => _submission.mode.isFriends
      ? const Color(0xFF0787FF)
      : const Color(0xFFE94494);

  String get _playerName {
    final session = ref.read(matchSessionProvider);
    final currentPlayerId = _activePlayerId;
    return resolveActivePlayerName(
      session: session,
      submission: _submission,
      activeParticipantId: currentPlayerId,
      fallback: ActivePlayerNameFallback.turn,
    );
  }

  String get _promptText => switch (widget.option) {
    TruthOrDareOption.verdad =>
      (widget.initialTurn ?? ref.read(matchCurrentTurnProvider))?.promptText ??
          'Describe el momento mas intenso que has vivido.',
    TruthOrDareOption.reto =>
      (widget.initialTurn ?? ref.read(matchCurrentTurnProvider))?.promptText ??
          'Acepta este reto frente a todos.',
  };

  int get _activePlayerId {
    final currentTurn =
        widget.initialTurn ?? ref.read(matchCurrentTurnProvider);
    if (currentTurn != null) {
      return currentTurn.participantId;
    }

    final session = ref.read(matchSessionProvider);
    if (session != null) {
      return session.currentParticipantId;
    }

    return _submission.players.isNotEmpty ? _submission.players.first.id : 1;
  }

  int get _currentPoints =>
      ref.read(matchScoresProvider)[_activePlayerId] ?? widget.points;

  Future<void> _openRoundScoreSummary({required bool didComplete}) async {
    if (_isResolvingTurn) {
      return;
    }
    setState(() {
      _isResolvingTurn = true;
    });

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
    ref.watch(matchSessionProvider);
    ref.watch(matchCurrentTurnProvider);
    ref.watch(matchScoresProvider);
    ref.watch(matchPendingLevelProvider);
    final selectedTheme =
        ref.read(matchPendingLevelProvider)?.toGameStyleTheme ??
        submission.selectedTheme;
    final themeAccent = selectedTheme.accentColor;

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
                  const Color(0x66050316),
                  const Color(0xFF06020F).withValues(alpha: 0.95),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.05),
                radius: 0.9,
                colors: [
                  themeAccent.withValues(alpha: 0.40),
                  themeAccent.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                stops: const [0, 0.34, 0.8],
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
                  SizedBox(
                    height: 92,
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              'assets/logo-+18.png',
                              width: 160,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        _HeaderSideButton(
                          onTap: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 170),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _playerName,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 48 * 0.76,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _PointsChip(points: _currentPoints),
                          const SizedBox(height: AppSpacing.xl),
                          _PromptCard(
                            iconAsset: selectedTheme.iconAsset,
                            accent: themeAccent,
                            promptText: _promptText,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: App3dPillButton(
                                  label: 'He cumplido',
                                  color: const Color(0xFFE9EBF1),
                                  leadingIcon: Icons.check_rounded,
                                  leadingIconColor: const Color(0xFF4D586D),
                                  leadingIconSize: 22,
                                  gradientColors: const [
                                    Color(0xFFF7F8FA),
                                    Color(0xFFE4E7EE),
                                  ],
                                  height: 70,
                                  depth: 4.4,
                                  borderRadius: 20,
                                  isLoading: _isResolvingTurn,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: const Color(0xFF4D586D),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 32 * 0.58,
                                      ),
                                  onTap: _isResolvingTurn
                                      ? null
                                      : () => _openRoundScoreSummary(
                                          didComplete: true,
                                        ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: App3dPillButton(
                                  label: 'Me dio miedo',
                                  color: submission.mode.isFriends
                                      ? const Color(0xFF5FC0FF)
                                      : const Color(0xFFF574B9),
                                  leadingIcon: Icons.close_rounded,
                                  leadingIconColor: Colors.white,
                                  leadingIconSize: 22,
                                  gradientColors: submission.mode.isFriends
                                      ? const [
                                          Color(0xFF5FC0FF),
                                          Color(0xFF2E6FC9),
                                        ]
                                      : const [
                                          Color(0xFFF574B9),
                                          Color(0xFFD93D88),
                                        ],
                                  height: 70,
                                  depth: 4.4,
                                  borderRadius: 20,
                                  isLoading: _isResolvingTurn,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 32 * 0.58,
                                      ),
                                  onTap: _isResolvingTurn
                                      ? null
                                      : () => _openRoundScoreSummary(
                                          didComplete: false,
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _RoundChip(
                            round: widget.round,
                            accentColor: _modeAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.iconAsset,
    required this.accent,
    required this.promptText,
  });

  final String iconAsset;
  final Color accent;
  final String promptText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFA1A1D22), Color(0xF2111318)],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.85), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.42),
            blurRadius: 26,
            spreadRadius: 0.8,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(iconAsset, width: 62, height: 62, fit: BoxFit.contain),
          const SizedBox(height: AppSpacing.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF05070C).withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.34),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              promptText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.94),
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                fontSize: 36 * 0.65,
                height: 1.16,
              ),
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
      height: 52,
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

class _RoundChip extends StatelessWidget {
  const _RoundChip({required this.round, required this.accentColor});

  final int round;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFF171A22).withValues(alpha: 0.82),
        border: Border.all(color: accentColor, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ronda',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.93),
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.98),
            ),
            child: Text(
              '$round',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSideButton extends StatelessWidget {
  const _HeaderSideButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 84,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF161037).withValues(alpha: 0.72),
                  const Color(0xFF120B2D).withValues(alpha: 0.62),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF9D2E8A).withValues(alpha: 0.48),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.chevron_left_rounded,
                size: 32,
                color: const Color(0xFFFF6FD7).withValues(alpha: 0.95),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
