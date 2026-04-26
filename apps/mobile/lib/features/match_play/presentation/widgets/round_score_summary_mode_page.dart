import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_3d_pill_button.dart';
import '../../domain/entities/active_match_effect.dart';
import '../providers/match_providers.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../../../player_setup/presentation/widgets/premium_glass_surface.dart';
import '../../../player_setup/presentation/widgets/round_top_header.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import 'current_effects_widgets.dart';

const _winnerGreenGradientTopBottom = <Color>[
  Color(0xFF63DD5A),
  Color(0xFF2CAA37),
];

class RoundScoreSummaryModePage extends ConsumerStatefulWidget {
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
    this.onFinishMatchTap,
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
  final VoidCallback? onFinishMatchTap;

  @override
  ConsumerState<RoundScoreSummaryModePage> createState() =>
      _RoundScoreSummaryModePageState();
}

class _RoundScoreSummaryModePageState
    extends ConsumerState<RoundScoreSummaryModePage> {
  Color get _negativeAccent => const Color(0xFFFF3A4D);

  Color get _statusAccent =>
      widget.didComplete ? const Color(0xFF2AF063) : _negativeAccent;

  Color get _statusGlowColor =>
      widget.didComplete ? const Color(0xFF69D33E) : _negativeAccent;

  int get _deltaPoints => widget.didComplete
      ? widget.gainedPoints.abs()
      : -widget.gainedPoints.abs();

  var _showEffectsText = false;

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

  String _safeName(PlayerConfig player) {
    final trimmed = player.name.trim();
    return trimmed.isEmpty ? 'Jugador ${player.id}' : trimmed;
  }

  int _scoreFor(int playerId) => widget.scoresByPlayerId[playerId] ?? 0;

  Map<int, int> get _playerRankById {
    final ranked = [..._players]
      ..sort((left, right) {
        final scoreCompare = _scoreFor(right.id).compareTo(_scoreFor(left.id));
        if (scoreCompare != 0) {
          return scoreCompare;
        }
        return left.id.compareTo(right.id);
      });

    final byId = <int, int>{};
    for (var i = 0; i < ranked.length; i++) {
      byId[ranked[i].id] = i + 1;
    }
    return byId;
  }

  int _rankFor(int playerId) => _playerRankById[playerId] ?? playerId;

  Future<void> _openSettings() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
  }

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

  int _pairScore(List<PlayerConfig> pair) =>
      pair.map((player) => _scoreFor(player.id)).fold<int>(0, (a, b) => a + b);

  int get _playerStanding {
    final completedScore = _scoreFor(widget.completedPlayerId);
    final betterScores = _players
        .where((player) => _scoreFor(player.id) > completedScore)
        .length;
    return betterScores + 1;
  }

  int get _pairStanding {
    if (_pairs.isEmpty) {
      return 1;
    }

    List<PlayerConfig>? completedPair;
    for (final pair in _pairs) {
      if (pair.any((player) => player.id == widget.completedPlayerId)) {
        completedPair = pair;
        break;
      }
    }
    final fallbackPair = _pairs.first;
    final targetPair = completedPair ?? fallbackPair;
    final targetScore = _pairScore(targetPair);
    final betterScores = _pairs
        .where((pair) => _pairScore(pair) > targetScore)
        .length;
    return betterScores + 1;
  }

  String get _positionMessage {
    final standing = widget.submission.mode.isCouples && _pairs.length > 1
        ? _pairStanding
        : _playerStanding;
    final verb = widget.submission.mode.isCouples ? 'van' : 'vas';
    return 'Ahora $verb ${standing <= 0 ? 1 : standing}º';
  }

  Future<void> _onEffectsSlideTap(List<ActiveMatchEffect> effects) async {
    if (!_showEffectsText) {
      setState(() {
        _showEffectsText = true;
      });
      return;
    }

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.74),
      builder: (_) => CurrentEffectsDialog(effects: effects),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedName = _safeName(_completedPlayer);
    final effects =
        ref.watch(matchSessionProvider)?.activeEffects ??
        const <ActiveMatchEffect>[];

    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBody: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(widget.backgroundAsset, fit: BoxFit.cover),
            _RoundScoreSummaryLightRays(accentColor: _statusGlowColor),
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
                  center: const Alignment(0, -0.18),
                  radius: 1.0,
                  colors: [
                    _statusGlowColor.withValues(alpha: 0.48),
                    _statusGlowColor.withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.40, 0.88],
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
                      round: widget.round,
                      isFriendsMode: widget.submission.mode.isFriends,
                      onBackTap: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      onSettingsTap: _openSettings,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 170),
                        child: Column(
                          children: [
                            const SizedBox(height: AppSpacing.sm),
                            RoundScoreSummaryCompactPointsChip(
                              points: _deltaPoints,
                                statusAccent: _statusAccent,

                            ),
                            const SizedBox(height: AppSpacing.md),
                            RoundScoreSummaryPlayerSpotlight(
                              player: _completedPlayer,
                              borderColor: _statusAccent,
                              didComplete: widget.didComplete,
                              playerName: completedName,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (widget.submission.mode.isCouples &&
                                _pairs.length > 1)
                              RoundScoreSummaryCouplesPairsSection(
                                pairs: _pairs,
                                completedPlayerId: widget.completedPlayerId,
                                scoreFor: _scoreFor,
                                rankForPlayerId: _rankFor,
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
                                rankForPlayerId: _rankFor,
                                baseCircleColor: widget.baseNumberCircle,
                                didComplete: widget.didComplete,
                                statusAccent: _statusAccent,
                              ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              _positionMessage,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 30 * 0.58,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            RoundScoreSummaryNextRoundButton(
                              onTap: widget.onNextRoundTap ?? () {},
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            RoundScoreSummaryFinishMatchButton(
                              gradient: widget.buttonGradient,
                              onTap: widget.onFinishMatchTap ?? () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                  onTap: () => _onEffectsSlideTap(effects),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundScoreSummaryLightRays extends StatelessWidget {
  const _RoundScoreSummaryLightRays({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _RoundScoreSummaryRaysPainter(color: accentColor),
      ),
    );
  }
}

class _RoundScoreSummaryRaysPainter extends CustomPainter {
  _RoundScoreSummaryRaysPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.38);
    final radius = size.longestSide * 0.82;
    const rayCount = 34;
    const darkness = Color(0x99000000);
    final rayPaint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < rayCount; i++) {
      final startAngle = (2 * math.pi * i) / rayCount;
      final sweep = (2 * math.pi / rayCount) * 0.52;
      final alpha = i.isEven ? 0.18 : 0.08;
      rayPaint.color = Color.lerp(
        color.withValues(alpha: alpha),
        darkness,
        i.isEven ? 0.12 : 0.38,
      )!;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweep,
          false,
        )
        ..close();
      canvas.drawPath(path, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoundScoreSummaryRaysPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class RoundScoreSummaryPlayerSpotlight extends StatelessWidget {
  const RoundScoreSummaryPlayerSpotlight({
    required this.player,
    required this.borderColor,
    required this.didComplete,
    required this.playerName,
    super.key,
  });

  final PlayerConfig player;
  final Color borderColor;
  final bool didComplete;
  final String playerName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 116,
          height: 116,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.42),
                blurRadius: 24,
                spreadRadius: 0.3,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(player.avatarAssetPath, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          playerName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 48 * 0.78,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          didComplete ? 'La rompiste!' : 'Toma shot',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.90),
            fontWeight: FontWeight.w500,
            fontSize: 34 * 0.56,
          ),
        ),
      ],
    );
  }
}

class RoundScoreSummaryCouplesPairsSection extends StatelessWidget {
  const RoundScoreSummaryCouplesPairsSection({
    required this.pairs,
    required this.completedPlayerId,
    required this.scoreFor,
    required this.rankForPlayerId,
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
  final int Function(int playerId) rankForPlayerId;
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
          ...() {
            final orderedPair = [...pairs[index]]
              ..sort((left, right) {
                final scoreCompare = scoreFor(
                  right.id,
                ).compareTo(scoreFor(left.id));
                if (scoreCompare != 0) {
                  return scoreCompare;
                }
                return left.id.compareTo(right.id);
              });

            return [
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
                      playerIndex < orderedPair.length;
                      playerIndex++
                    ) ...[
                      RoundScoreSummaryScoreRow(
                        player: orderedPair[playerIndex],
                        score: scoreFor(orderedPair[playerIndex].id),
                        rank: rankForPlayerId(orderedPair[playerIndex].id),
                        highlight:
                            orderedPair[playerIndex].id == completedPlayerId,
                        baseCircleColor: baseCircleColor,
                        didComplete: didComplete,
                        statusAccent: statusAccent,
                      ),
                      if (playerIndex != orderedPair.length - 1)
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
                          orderedPair.any(
                            (player) => player.id == completedPlayerId,
                          ),
                    ),
                  ],
                ),
              ),
            ];
          }(),
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
    required this.rankForPlayerId,
    required this.baseCircleColor,
    required this.didComplete,
    required this.statusAccent,
    super.key,
  });

  final List<PlayerConfig> players;
  final int completedPlayerId;
  final int Function(int playerId) scoreFor;
  final int Function(int playerId) rankForPlayerId;
  final Color baseCircleColor;
  final bool didComplete;
  final Color statusAccent;

  @override
  Widget build(BuildContext context) {
    final orderedPlayers = [...players]
      ..sort((left, right) {
        final scoreCompare = scoreFor(right.id).compareTo(scoreFor(left.id));
        if (scoreCompare != 0) {
          return scoreCompare;
        }
        return left.id.compareTo(right.id);
      });

    return Column(
      children: [
        for (var i = 0; i < orderedPlayers.length; i++) ...[
          RoundScoreSummaryScoreRow(
            player: orderedPlayers[i],
            score: scoreFor(orderedPlayers[i].id),
            rank: rankForPlayerId(orderedPlayers[i].id),
            highlight: orderedPlayers[i].id == completedPlayerId,
            baseCircleColor: baseCircleColor,
            didComplete: didComplete,
            statusAccent: statusAccent,
          ),
          if (i != orderedPlayers.length - 1)
            const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class RoundScoreSummaryScoreRow extends StatelessWidget {
  const RoundScoreSummaryScoreRow({
    required this.player,
    required this.score,
    required this.rank,
    required this.highlight,
    required this.baseCircleColor,
    required this.didComplete,
    required this.statusAccent,
    super.key,
  });

  final PlayerConfig player;
  final int score;
  final int rank;
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
                      colors: _winnerGreenGradientTopBottom,
                    )
                  : null,
            ),
            child: highlight
                ? Icon(
                    didComplete
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: Colors.white,
                    size: 24,
                  )
                : Text(
                    '$rank',
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
              ? _winnerGreenGradientTopBottom
              : const [Color(0xFFF24B45), Color(0xFFD7382C)])
        : null;
    final bg = highlight ? null : const Color(0xFFF2F3F6);
    final textColor = highlight ? Colors.white : const Color(0xFF344054);

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
            '$score',
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
            highlightLoss ? '-$pointsDelta' : '$pairScore',
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
  const RoundScoreSummaryCompactPointsChip({required this.points,
  required this.statusAccent,
   super.key});

  final int points;
  final Color statusAccent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      height: 49,
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
              color: statusAccent.withValues(alpha: 0.86),
              fontWeight: FontWeight.w500,
              fontSize: 15,
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
  const RoundScoreSummaryNextRoundButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return App3dPillButton(
      label: 'Siguiente',
      color: const Color(0xFFF7F8FA),
      gradientColors: const [Color(0xFFF7F8FA), Color(0xFFE4E7EE)],
      height: 62,
      depth: 4.4,
      borderRadius: 16,
      textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: const Color(0xFF0F1115),
        fontWeight: FontWeight.w500,
        fontSize: 32 * 0.58,
      ),
      onTap: onTap,
    );
  }
}

class RoundScoreSummaryFinishMatchButton extends StatelessWidget {
  const RoundScoreSummaryFinishMatchButton({
    required this.gradient,
    required this.onTap,
    super.key,
  });

  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.74,
      child: App3dPillButton(
        label: 'Finalizar partida',
        color: gradient.first,
        gradientColors: gradient,
        height: 56,
        depth: 4,
        borderRadius: 16,
        textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white.withValues(alpha: 0.96),
          fontWeight: FontWeight.w600,
          fontSize: 32 * 0.58,
        ),
        onTap: onTap,
      ),
    );
  }
}
