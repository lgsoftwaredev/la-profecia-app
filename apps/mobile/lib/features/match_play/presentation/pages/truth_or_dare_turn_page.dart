import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_3d_pill_button.dart';
import '../../../../core/widgets/global_bottom_menu.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../../domain/entities/truth_or_dare_option.dart';
import 'round_score_summary_page.dart';

class TruthOrDareTurnPage extends StatefulWidget {
  const TruthOrDareTurnPage({
    required this.submission,
    required this.option,
    this.round = 1,
    this.points = 0,
    super.key,
  });

  final GameSetupSubmission submission;
  final TruthOrDareOption option;
  final int round;
  final int points;

  @override
  State<TruthOrDareTurnPage> createState() => _TruthOrDareTurnPageState();
}

class _TruthOrDareTurnPageState extends State<TruthOrDareTurnPage> {
  var _bottomMenuItem = GlobalBottomMenuItem.home;

  String get _backgroundAsset => widget.submission.mode.isFriends
      ? 'assets/background-setup-friends-mode.png'
      : 'assets/background-setup-couple-mode.png';

  Color get _modeAccent => widget.submission.mode.isFriends
      ? const Color(0xFF0787FF)
      : const Color(0xFFE94494);

  String get _playerName {
    for (final player in widget.submission.players) {
      final name = player.name.trim();
      if (name.isNotEmpty) {
        return name;
      }
    }
    return 'Jugador';
  }

  String get _promptText => switch (widget.option) {
    TruthOrDareOption.verdad =>
      'Describe el momento más\nintenso que has vivido...\n\nSin suavizar nada.',
    TruthOrDareOption.reto =>
      'Acepta este reto frente\na todos.\n\nNada de echarte atrás.',
  };

  int get _activePlayerId {
    for (final player in widget.submission.players) {
      if (player.name.trim().isNotEmpty) {
        return player.id;
      }
    }
    return widget.submission.players.isNotEmpty
        ? widget.submission.players.first.id
        : 1;
  }

  Map<int, int> _demoScores({required bool didComplete}) {
    final ids = widget.submission.players
        .map((player) => player.id)
        .toList(growable: false);
    if (ids.isEmpty) {
      return const {};
    }

    if (widget.submission.mode.isFriends) {
      final values = [30, 0, 5, 0, 0, 0, 0, 0];
      final map = <int, int>{};
      for (var i = 0; i < ids.length; i++) {
        map[ids[i]] = values[i < values.length ? i : values.length - 1];
      }
      map[_activePlayerId] = didComplete ? 10 : -10;
      return map;
    }

    final hasMultiplePairs = widget.submission.pairs.length > 1;
    if (hasMultiplePairs) {
      final values = [30, 0, 30, 30, 0, 0, 0, 0];
      final map = <int, int>{};
      for (var i = 0; i < ids.length; i++) {
        map[ids[i]] = values[i < values.length ? i : values.length - 1];
      }
      map[_activePlayerId] = didComplete ? 10 : -10;
      return map;
    }

    final map = <int, int>{ids.first: 30, if (ids.length > 1) ids[1]: 0};
    map[_activePlayerId] = didComplete ? 10 : -10;
    return map;
  }

  void _openRoundScoreSummary({required bool didComplete}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoundScoreSummaryPage(
          submission: widget.submission,
          completedPlayerId: _activePlayerId,
          scoresByPlayerId: _demoScores(didComplete: didComplete),
          round: widget.round,
          gainedPoints: 10,
          didComplete: didComplete,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeAccent = widget.submission.selectedTheme.accentColor;

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
                          _PointsChip(points: widget.points),
                          const SizedBox(height: AppSpacing.xl),
                          _PromptCard(
                            iconAsset:
                                widget.submission.selectedTheme.iconAsset,
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
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: const Color(0xFF4D586D),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 32 * 0.58,
                                      ),
                                  onTap: () =>
                                      _openRoundScoreSummary(didComplete: true),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: App3dPillButton(
                                  label: 'Me dio miedo',
                                  color: widget.submission.mode.isFriends
                                      ? const Color(0xFF5FC0FF)
                                      : const Color(0xFFF574B9),
                                  leadingIcon: Icons.close_rounded,
                                  leadingIconColor: Colors.white,
                                  leadingIconSize: 22,
                                  gradientColors:
                                      widget.submission.mode.isFriends
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
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 32 * 0.58,
                                      ),
                                  onTap: () => _openRoundScoreSummary(
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
      bottomNavigationBar: GlobalBottomMenu(
        currentItem: _bottomMenuItem,
        onItemSelected: (item) {
          setState(() {
            _bottomMenuItem = item;
          });
          if (item == GlobalBottomMenuItem.home &&
              Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
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
