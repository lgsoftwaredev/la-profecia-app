import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_3d_pill_button.dart';
import '../../../../core/widgets/global_bottom_menu.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../../../player_setup/presentation/widgets/premium_glass_surface.dart';

class RoundScoreSummaryModePage extends StatefulWidget {
  const RoundScoreSummaryModePage({
    required this.submission,
    required this.completedPlayerId,
    required this.scoresByPlayerId,
    required this.backgroundAsset,
    required this.modeAccent,
    required this.buttonGradient,
    required this.baseNumberCircle,
    this.round = 1,
    this.gainedPoints = 10,
    this.didComplete = true,
    this.usePremiumPairCards = false,
    this.pairTotalChipHeight = 42,
    this.pairCardTopHighlightOpacity = 0,
    this.pairCardBottomShadeOpacity = 0,
    this.pairCardInnerBorderAlpha = 0,
    this.onNextRoundTap,
    super.key,
  });

  final GameSetupSubmission submission;
  final int completedPlayerId;
  final Map<int, int> scoresByPlayerId;
  final String backgroundAsset;
  final Color modeAccent;
  final List<Color> buttonGradient;
  final Color baseNumberCircle;
  final int round;
  final int gainedPoints;
  final bool didComplete;
  final bool usePremiumPairCards;
  final double pairTotalChipHeight;
  final double pairCardTopHighlightOpacity;
  final double pairCardBottomShadeOpacity;
  final double pairCardInnerBorderAlpha;
  final VoidCallback? onNextRoundTap;

  @override
  State<RoundScoreSummaryModePage> createState() =>
      _RoundScoreSummaryModePageState();
}

class _RoundScoreSummaryModePageState extends State<RoundScoreSummaryModePage> {
  var _bottomMenuItem = GlobalBottomMenuItem.home;

  Color get _negativeAccent => const Color(0xFFFF3A4D);

  Color get _statusAccent =>
      widget.didComplete ? const Color(0xFF2AF063) : _negativeAccent;

  Color get _statusGlowColor =>
      widget.didComplete ? const Color(0xFF69D33E) : _negativeAccent;

  int get _deltaPoints => widget.didComplete
      ? widget.gainedPoints.abs()
      : -widget.gainedPoints.abs();

  List<PlayerConfig> get _players {
    final named = widget.submission.players
        .where((player) => player.name.trim().isNotEmpty)
        .toList(growable: false);
    return named.isNotEmpty ? named : widget.submission.players;
  }

  PlayerConfig get _completedPlayer {
    for (final player in _players) {
      if (player.id == widget.completedPlayerId) {
        return player;
      }
    }
    return _players.first;
  }

  int _scoreFor(int playerId) => widget.scoresByPlayerId[playerId] ?? 0;

  List<List<PlayerConfig>> get _pairs {
    if (widget.submission.pairs.isNotEmpty) {
      return widget.submission.pairs;
    }
    final players = _players;
    final list = <List<PlayerConfig>>[];
    for (var i = 0; i < players.length; i += 2) {
      list.add(players.skip(i).take(2).toList(growable: false));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final completedName = _completedPlayer.name.trim().isEmpty
        ? 'Jugador ${_completedPlayer.id}'
        : _completedPlayer.name.trim();

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(widget.backgroundAsset, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0x5C050316),
                  const Color(0xFF06020F).withValues(alpha: 0.95),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.05),
                radius: 0.96,
                colors: [
                  _statusGlowColor.withValues(alpha: 0.42),
                  _statusGlowColor.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                stops: const [0, 0.36, 0.82],
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
                        RoundScoreSummaryHeaderSideButton(
                          accent: widget.modeAccent,
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
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '$completedName ${widget.didComplete ? 'ha cumplido' : 'no ha cumplido'}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontSize: 38 * 0.66,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: widget.didComplete
                                      ? 'Ha conseguido '
                                      : 'Ha descontado ',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                ),
                                TextSpan(
                                  text:
                                      '${_deltaPoints >= 0 ? '+' : ''}$_deltaPoints puntos',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: widget.didComplete
                                            ? const Color(0xFFFFB000)
                                            : _negativeAccent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            completedName,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 48 * 0.78,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          RoundScoreSummaryCompactPointsChip(
                            points: _deltaPoints,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Puntaje Ronda ${widget.round}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (widget.submission.mode.isCouples &&
                              _pairs.length > 1)
                            RoundScoreSummaryCouplesPairsSection(
                              pairs: _pairs,
                              completedPlayerId: widget.completedPlayerId,
                              scoreFor: _scoreFor,
                              baseCircleColor: widget.baseNumberCircle,
                              didComplete: widget.didComplete,
                              statusAccent: _statusAccent,
                              lostPoints: widget.gainedPoints.abs(),
                              usePremiumPairCards: widget.usePremiumPairCards,
                              pairTotalChipHeight: widget.pairTotalChipHeight,
                              pairCardTopHighlightOpacity:
                                  widget.pairCardTopHighlightOpacity,
                              pairCardBottomShadeOpacity:
                                  widget.pairCardBottomShadeOpacity,
                              pairCardInnerBorderAlpha:
                                  widget.pairCardInnerBorderAlpha,
                            )
                          else
                            RoundScoreSummaryScoreRowsSection(
                              players: widget.submission.mode.isCouples
                                  ? (_pairs.isNotEmpty
                                        ? _pairs.first
                                        : _players)
                                  : _players,
                              completedPlayerId: widget.completedPlayerId,
                              scoreFor: _scoreFor,
                              baseCircleColor: widget.baseNumberCircle,
                              didComplete: widget.didComplete,
                              statusAccent: _statusAccent,
                            ),
                          const SizedBox(height: AppSpacing.lg),
                          RoundScoreSummaryRoundChip(
                            round: widget.round,
                            accentColor: widget.modeAccent,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          RoundScoreSummaryNextRoundButton(
                            gradient: widget.buttonGradient,
                            onTap:
                                widget.onNextRoundTap ??
                                () {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  }
                                },
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

class RoundScoreSummaryCouplesPairsSection extends StatelessWidget {
  const RoundScoreSummaryCouplesPairsSection({
    required this.pairs,
    required this.completedPlayerId,
    required this.scoreFor,
    required this.baseCircleColor,
    required this.didComplete,
    required this.statusAccent,
    required this.lostPoints,
    required this.usePremiumPairCards,
    required this.pairTotalChipHeight,
    required this.pairCardTopHighlightOpacity,
    required this.pairCardBottomShadeOpacity,
    required this.pairCardInnerBorderAlpha,
    super.key,
  });

  final List<List<PlayerConfig>> pairs;
  final int completedPlayerId;
  final int Function(int playerId) scoreFor;
  final Color baseCircleColor;
  final bool didComplete;
  final Color statusAccent;
  final int lostPoints;
  final bool usePremiumPairCards;
  final double pairTotalChipHeight;
  final double pairCardTopHighlightOpacity;
  final double pairCardBottomShadeOpacity;
  final double pairCardInnerBorderAlpha;

  double _pairCardHeight(BuildContext context, int playerCount) {
    final safePlayerCount = playerCount <= 0 ? 1 : playerCount;
    final scaledTitleHeight =
        16 * 1.2 * MediaQuery.textScalerOf(context).scale(1);
    final playersBlockHeight =
        (72 * safePlayerCount) + (AppSpacing.sm * (safePlayerCount - 1));

    return (AppSpacing.sm * 3.5) +
        scaledTitleHeight +
        AppSpacing.sm +
        playersBlockHeight +
        AppSpacing.sm +
        pairTotalChipHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < pairs.length; index++) ...[
          _PairCard(
            height: _pairCardHeight(context, pairs[index].length),
            usePremiumSurface: usePremiumPairCards,
            topHighlightOpacity: pairCardTopHighlightOpacity,
            bottomShadeOpacity: pairCardBottomShadeOpacity,
            innerBorderAlpha: pairCardInnerBorderAlpha,
            child: Column(
              children: [
                Text(
                  'Pareja ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (
                  var playerIndex = 0;
                  playerIndex < pairs[index].length;
                  playerIndex++
                ) ...[
                  RoundScoreSummaryScoreRow(
                    player: pairs[index][playerIndex],
                    score: scoreFor(pairs[index][playerIndex].id),
                    highlight:
                        pairs[index][playerIndex].id == completedPlayerId,
                    baseCircleColor: baseCircleColor,
                    didComplete: didComplete,
                    statusAccent: statusAccent,
                  ),
                  if (playerIndex != pairs[index].length - 1)
                    const SizedBox(height: AppSpacing.sm),
                ],
                const SizedBox(height: AppSpacing.sm),
                RoundScoreSummaryPairTotalChip(
                  pairScore: pairs[index]
                      .map((player) => scoreFor(player.id))
                      .fold<int>(0, (sum, score) => sum + score),
                  pointsDelta: lostPoints,
                  height: pairTotalChipHeight,
                  highlightLoss:
                      !didComplete &&
                      pairs[index].any(
                        (player) => player.id == completedPlayerId,
                      ),
                ),
              ],
            ),
          ),
          if (index != pairs.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _PairCard extends StatelessWidget {
  const _PairCard({
    required this.height,
    required this.usePremiumSurface,
    required this.topHighlightOpacity,
    required this.bottomShadeOpacity,
    required this.innerBorderAlpha,
    required this.child,
  });

  final double height;
  final bool usePremiumSurface;
  final double topHighlightOpacity;
  final double bottomShadeOpacity;
  final double innerBorderAlpha;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!usePremiumSurface) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x8A476D51), Color(0x8A1B1E30)],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
            width: 1,
          ),
        ),
        child: child,
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: PremiumGlassSurface(
        borderRadius: BorderRadius.circular(16),
        gradientColors: const [
          Color.fromARGB(0, 71, 109, 81),
          Color(0x8A1B1E30),
        ],
        borderColor: Colors.white.withValues(alpha: 0.14),
        innerBorderColor: Colors.white.withValues(alpha: innerBorderAlpha),
        topHighlightOpacity: topHighlightOpacity,
        bottomShadeOpacity: bottomShadeOpacity,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: child,
      ),
    );
  }
}

class RoundScoreSummaryScoreRowsSection extends StatelessWidget {
  const RoundScoreSummaryScoreRowsSection({
    required this.players,
    required this.completedPlayerId,
    required this.scoreFor,
    required this.baseCircleColor,
    required this.didComplete,
    required this.statusAccent,
    super.key,
  });

  final List<PlayerConfig> players;
  final int completedPlayerId;
  final int Function(int playerId) scoreFor;
  final Color baseCircleColor;
  final bool didComplete;
  final Color statusAccent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < players.length; i++) ...[
          RoundScoreSummaryScoreRow(
            player: players[i],
            score: scoreFor(players[i].id),
            highlight: players[i].id == completedPlayerId,
            baseCircleColor: baseCircleColor,
            didComplete: didComplete,
            statusAccent: statusAccent,
          ),
          if (i != players.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class RoundScoreSummaryScoreRow extends StatelessWidget {
  const RoundScoreSummaryScoreRow({
    required this.player,
    required this.score,
    required this.highlight,
    required this.baseCircleColor,
    required this.didComplete,
    required this.statusAccent,
    super.key,
  });

  final PlayerConfig player;
  final int score;
  final bool highlight;
  final Color baseCircleColor;
  final bool didComplete;
  final Color statusAccent;

  @override
  Widget build(BuildContext context) {
    final safeName = player.name.trim().isEmpty
        ? 'Jugador ${player.id}'
        : player.name.trim();

    return PremiumGlassSurface(
      height: 72,
      borderRadius: BorderRadius.circular(26),
      gradientColors: const [Color.fromARGB(0, 76, 123, 85), Color(0xB2222A3B)],
      borderColor: highlight
          ? statusAccent
          : Colors.white.withValues(alpha: 0.3),
      innerBorderColor: highlight
          ? statusAccent.withValues(alpha: 0.52)
          : Colors.white.withValues(alpha: 0.01),
      topHighlightOpacity: highlight ? 0.20 : 0.0,
      bottomShadeOpacity: highlight ? 0.12 : 0.0,
      outerShadows: highlight
          ? [
              BoxShadow(
                color: statusAccent.withValues(alpha: 0.35),
                blurRadius: 6,
                spreadRadius: 0.1,
              ),
            ]
          : const [],
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: !highlight
                  ? baseCircleColor
                  : (didComplete ? null : statusAccent),
              gradient: highlight && didComplete
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: AppColors.winnerGradientTopBottom,
                    )
                  : null,
            ),
            child: Text(
              '${player.id}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 26 * 0.7,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              safeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.94),
                fontWeight: FontWeight.w500,
                fontSize: 30 * 0.54,
              ),
            ),
          ),
          RoundScoreSummaryScorePill(
            score: score,
            highlight: highlight,
            didComplete: didComplete,
          ),
        ],
      ),
    );
  }
}

class RoundScoreSummaryScorePill extends StatelessWidget {
  const RoundScoreSummaryScorePill({
    required this.score,
    required this.highlight,
    required this.didComplete,
    super.key,
  });

  final int score;
  final bool highlight;
  final bool didComplete;

  @override
  Widget build(BuildContext context) {
    final gradient = highlight
        ? (didComplete
              ? AppColors.winnerGradientTopBottom
              : const [Color(0xFFF24B45), Color(0xFFD7382C)])
        : null;
    final bg = highlight ? null : const Color(0xFFF2F3F6);
    final textColor = highlight
        ? (didComplete ? const Color(0xFF8A6700) : Colors.white)
        : const Color(0xFF344054);

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: gradient == null
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradient,
              ),
        color: bg,
      ),
      child: Row(
        children: [
          Text(
            score >= 0 ? '+$score' : '$score',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/logo-icon-start-points.png',
            width: 22,
            height: 22,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class RoundScoreSummaryPairTotalChip extends StatelessWidget {
  const RoundScoreSummaryPairTotalChip({
    required this.pairScore,
    required this.pointsDelta,
    required this.height,
    this.highlightLoss = false,
    super.key,
  });

  final int pairScore;
  final int pointsDelta;
  final double height;
  final bool highlightLoss;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFF0A0E13).withValues(alpha: 0.82),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Puntaje de pareja',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            highlightLoss ? '-$pointsDelta' : '+$pairScore',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: highlightLoss
                  ? const Color(0xFFFF3A4D)
                  : Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
              fontSize: 30 * 0.58,
            ),
          ),
          const SizedBox(width: 10),
          Image.asset(
            'assets/logo-icon-start-points.png',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class RoundScoreSummaryCompactPointsChip extends StatelessWidget {
  const RoundScoreSummaryCompactPointsChip({required this.points, super.key});

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
            '${points >= 0 ? '+' : ''}$points puntos',
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

class RoundScoreSummaryRoundChip extends StatelessWidget {
  const RoundScoreSummaryRoundChip({
    required this.round,
    required this.accentColor,
    super.key,
  });

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

class RoundScoreSummaryNextRoundButton extends StatelessWidget {
  const RoundScoreSummaryNextRoundButton({
    required this.gradient,
    required this.onTap,
    super.key,
  });

  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return App3dPillButton(
      label: 'Siguiente ronda',
      color: gradient.first,
      gradientColors: gradient,
      height: 62,
      depth: 4.4,
      borderRadius: 16,
      textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 32 * 0.58,
      ),
      onTap: onTap,
    );
  }
}

class RoundScoreSummaryHeaderSideButton extends StatelessWidget {
  const RoundScoreSummaryHeaderSideButton({
    required this.accent,
    required this.onTap,
    super.key,
  });

  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bright = Color.lerp(accent, Colors.white, 0.4)!;
    final dark = Color.lerp(accent, const Color(0xFF120B2D), 0.7)!;

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
                  bright.withValues(alpha: 0.22),
                  dark.withValues(alpha: 0.52),
                ],
              ),
              border: Border.all(
                color: accent.withValues(alpha: 0.56),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.chevron_left_rounded,
                size: 32,
                color: accent.withValues(alpha: 0.98),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
