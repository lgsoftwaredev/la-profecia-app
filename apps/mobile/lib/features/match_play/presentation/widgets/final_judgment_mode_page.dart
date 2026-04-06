import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_3d_pill_button.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../pages/final_group_challenge_page.dart';
import '../pages/final_prophecy_challenge_page.dart';
import '../../../player_setup/presentation/widgets/premium_glass_surface.dart';

class FinalJudgmentModePage extends StatefulWidget {
  const FinalJudgmentModePage({
    required this.submission,
    required this.scoresByPlayerId,
    this.onProphecyChallengeTap,
    this.onGroupDecisionTap,
    super.key,
  });

  final GameSetupSubmission submission;
  final Map<int, int> scoresByPlayerId;
  final VoidCallback? onProphecyChallengeTap;
  final VoidCallback? onGroupDecisionTap;

  @override
  State<FinalJudgmentModePage> createState() => _FinalJudgmentModePageState();
}

class _FinalJudgmentModePageState extends State<FinalJudgmentModePage> {
  Color get _modeAccent => widget.submission.mode.isFriends
      ? const Color(0xFF2A9DFF)
      : const Color(0xFFE94494);

  String get _backgroundAsset => widget.submission.mode.isFriends
      ? 'assets/background-setup-friends-mode.png'
      : 'assets/background-setup-couple-mode.png';

  List<PlayerConfig> get _players {
    final named = widget.submission.players
        .where((player) => player.name.trim().isNotEmpty)
        .toList(growable: false);
    return named.isNotEmpty ? named : widget.submission.players;
  }

  int _scoreFor(int playerId) => widget.scoresByPlayerId[playerId] ?? 0;

  List<_RankedPlayer> get _rankedPlayers {
    final ranked = _players
        .map(
          (player) =>
              _RankedPlayer(player: player, score: _scoreFor(player.id)),
        )
        .toList(growable: false);

    ranked.sort((left, right) => right.score.compareTo(left.score));
    return ranked;
  }

  List<List<PlayerConfig>> get _pairs {
    if (widget.submission.pairs.isNotEmpty) {
      return widget.submission.pairs;
    }
    final list = <List<PlayerConfig>>[];
    for (var i = 0; i < _players.length; i += 2) {
      list.add(_players.skip(i).take(2).toList(growable: false));
    }
    return list;
  }

  bool get _showPairRanking =>
      widget.submission.mode.isCouples && _pairs.length > 1;

  List<_PairScoreSummary> get _pairSummaries {
    final summaries = <_PairScoreSummary>[];
    for (var index = 0; index < _pairs.length; index++) {
      final pairPlayers = _pairs[index];
      final pairScore = pairPlayers
          .map((player) => _scoreFor(player.id))
          .fold<int>(0, (sum, score) => sum + score);
      summaries.add(
        _PairScoreSummary(
          pairNumber: index + 1,
          players: pairPlayers,
          pairScore: pairScore,
        ),
      );
    }

    summaries.sort((left, right) => left.pairScore.compareTo(right.pairScore));
    return summaries;
  }

  String _safeName(PlayerConfig player) {
    final trimmed = player.name.trim();
    return trimmed.isEmpty ? 'Jugador ${player.id}' : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final rankedPlayers = _rankedPlayers;
    final pairSummaries = _pairSummaries;

    final loserLabel = _showPairRanking
        ? 'Pareja ${pairSummaries.first.pairNumber}'
        : (rankedPlayers.isNotEmpty
              ? _safeName(rankedPlayers.last.player)
              : '---');

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
                  const Color(0xFF06020F).withValues(alpha: 0.96),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 0.05),
                radius: 0.88,
                colors: [
                  (widget.submission.mode.isFriends
                          ? const Color(0xFF2562B8)
                          : const Color(0xFFB90E32))
                      .withValues(alpha: 0.50),
                  Colors.transparent,
                ],
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
                        _FinalHeaderButton(
                          accent: _modeAccent,
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
                            'Juicio Final',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: _modeAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 48 * 0.68,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Clasificación Final',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 34 * 0.64,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Puntajes',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.96),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (_showPairRanking)
                            _PairsRankingSection(
                              pairSummaries: pairSummaries,
                              scoreFor: _scoreFor,
                              safeName: _safeName,
                            )
                          else
                            _FinalRankingSection(
                              rankedPlayers: rankedPlayers,
                              safeName: _safeName,
                            ),
                          const SizedBox(height: 22),
                          Text(
                            _showPairRanking
                                ? 'Los perdedores son:'
                                : 'El perdedor es:',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: const Color.fromARGB(255, 227, 24, 24),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _LoserChip(label: loserLabel),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Quien decidira el castigo?',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          App3dPillButton(
                            label: 'Reto de la profecía',
                            color: const Color.fromARGB(255, 191, 191, 192),
                            gradientColors: const [
                              Color(0xFFF7F8FA),
                              Color(0xFFE4E7EE),
                            ],
                            height: 62,
                            depth: 4.4,
                            borderRadius: 16,
                            textStyle: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: const Color(0xFF4D586D),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 32 * 0.58,
                                ),
                            onTap:
                                widget.onProphecyChallengeTap ??
                                () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          FinalProphecyChallengePage(
                                            submission: widget.submission,
                                            punishedLabel: loserLabel,
                                          ),
                                    ),
                                  );
                                },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          App3dPillButton(
                            label: 'El grupo',
                            color: widget.submission.mode.isFriends
                                ? const Color.fromARGB(255, 41, 169, 255)
                                : const Color(0xFFF574B9),
                            gradientColors: widget.submission.mode.isFriends
                                ? const [
                                    Color.fromARGB(255, 50, 168, 247),
                                    Color.fromARGB(255, 32, 114, 229),
                                  ]
                                : const [Color(0xFFF574B9), Color(0xFFD93D88)],
                            height: 62,
                            depth: 4.4,
                            borderRadius: 16,
                            textStyle: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 32 * 0.58,
                                ),
                            onTap:
                                widget.onGroupDecisionTap ??
                                () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => FinalGroupChallengePage(
                                        submission: widget.submission,
                                        punishedLabel: loserLabel,
                                      ),
                                    ),
                                  );
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
    );
  }
}

class _FinalRankingSection extends StatelessWidget {
  const _FinalRankingSection({
    required this.rankedPlayers,
    required this.safeName,
  });

  final List<_RankedPlayer> rankedPlayers;
  final String Function(PlayerConfig player) safeName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < rankedPlayers.length; index++) ...[
          _FinalScoreRow(
            rank: index + 1,
            player: rankedPlayers[index].player,
            score: rankedPlayers[index].score,
            subtitle: index == 0
                ? 'Ganador'
                : (index == rankedPlayers.length - 1 ? 'Perdedor' : null),
            safeName: safeName,
            highlightedWinner: index == 0,
            highlightedLoser: index == rankedPlayers.length - 1,
          ),
          if (index != rankedPlayers.length - 1)
            const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _FinalScoreRow extends StatelessWidget {
  const _FinalScoreRow({
    required this.rank,
    required this.player,
    required this.score,
    required this.safeName,
    this.subtitle,
    this.highlightedWinner = false,
    this.highlightedLoser = false,
  });

  final int rank;
  final PlayerConfig player;
  final int score;
  final String? subtitle;
  final String Function(PlayerConfig player) safeName;
  final bool highlightedWinner;
  final bool highlightedLoser;

  @override
  Widget build(BuildContext context) {
    final borderColor = highlightedWinner
        ? const Color(0xFFF5D359)
        : (highlightedLoser
              ? const Color(0xFFFF4E4A)
              : Colors.white.withValues(alpha: 0.35));

    final backgroundGradient = highlightedLoser
        ? [
            const Color(0xFF5A2837).withValues(alpha: 0.88),
            const Color(0xFF2D1F34).withValues(alpha: 0.86),
          ]
        : [
            const Color(0xFF3A5D85).withValues(alpha: 0.86),
            const Color(0xFF23374F).withValues(alpha: 0.84),
          ];

    final badgeColor = highlightedWinner
        ? const Color(0xFFF8BE2A)
        : (highlightedLoser
              ? const Color(0xFFE63F35)
              : const Color(0xFF0787FF));

    final pointsGradient = highlightedWinner
        ? AppColors.winnerGradientTopBottom
        : (highlightedLoser
              ? const [Color(0xFFF24B45), Color(0xFFD7382C)]
              : const [Color(0xFFFFFFFF), Color(0xFFF2F3F6)]);

    final pointsTextColor = highlightedWinner
        ? const Color(0xFF946A00)
        : (highlightedLoser ? Colors.white : const Color(0xFF4D586D));

    return PremiumGlassSurface(
      height: 78,
      borderRadius: BorderRadius.circular(26),
      gradientColors: backgroundGradient,
      borderColor: borderColor,
      innerBorderColor: borderColor.withValues(alpha: 0.28),
      topHighlightOpacity: highlightedWinner ? 0.2 : 0.12,
      bottomShadeOpacity: 0.14,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlightedWinner ? null : badgeColor,
              gradient: highlightedWinner
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: AppColors.winnerGradientTopBottom,
                    )
                  : null,
            ),
            child: Text(
              '$rank',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  safeName(player),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.96),
                    fontWeight: FontWeight.w700,
                    fontSize: 34 * 0.56,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w500,
                      fontSize: 28 * 0.52,
                    ),
                  ),
              ],
            ),
          ),
          _ScorePill(
            score: score,
            textColor: pointsTextColor,
            gradient: pointsGradient,
          ),
        ],
      ),
    );
  }
}

class _PairsRankingSection extends StatelessWidget {
  const _PairsRankingSection({
    required this.pairSummaries,
    required this.scoreFor,
    required this.safeName,
  });

  final List<_PairScoreSummary> pairSummaries;
  final int Function(int playerId) scoreFor;
  final String Function(PlayerConfig player) safeName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < pairSummaries.length; index++) ...[
          _PairRankCard(
            pair: pairSummaries[index],
            isLoserPair: index == 0,
            isWinnerPair: index == pairSummaries.length - 1,
            scoreFor: scoreFor,
            safeName: safeName,
          ),
          if (index != pairSummaries.length - 1)
            const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _PairRankCard extends StatelessWidget {
  const _PairRankCard({
    required this.pair,
    required this.isLoserPair,
    required this.isWinnerPair,
    required this.scoreFor,
    required this.safeName,
  });

  final _PairScoreSummary pair;
  final bool isLoserPair;
  final bool isWinnerPair;
  final int Function(int playerId) scoreFor;
  final String Function(PlayerConfig player) safeName;

  @override
  Widget build(BuildContext context) {
    final borderColor = isLoserPair
        ? Color(0xFFFF5A4C)
        : const Color.fromARGB(0, 243, 229, 103);

    final title = isLoserPair
        ? 'Pareja ${pair.pairNumber} perdedores'
        : (isWinnerPair
              ? 'Pareja ${pair.pairNumber} Ganadores'
              : 'Pareja ${pair.pairNumber}');

    final titleHeight = 15 * 1.2 * MediaQuery.textScalerOf(context).scale(1);
    final playersCount = pair.players.isEmpty ? 1 : pair.players.length;
    final playersBlockHeight =
        (46 * playersCount) + (AppSpacing.sm * (playersCount - 1));
    final cardHeight =
        (AppSpacing.sm * 7.7) +
        titleHeight +
        AppSpacing.sm +
        playersBlockHeight +
        AppSpacing.sm +
        44;

    return SizedBox(
      width: double.infinity,
      height: cardHeight,
      child: PremiumGlassSurface(
        borderRadius: BorderRadius.circular(18),
        gradientColors: [
          const Color.fromARGB(0, 111, 42, 61),
          const Color.fromARGB(0, 111, 42, 61),
        ],
        borderColor: borderColor,
        topHighlightOpacity: 0.2,
        bottomShadeOpacity: 0.18,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var index = 0; index < pair.players.length; index++) ...[
              _PairPlayerRow(
                player: pair.players[index],
                score: scoreFor(pair.players[index].id),
                safeName: safeName,
                isWinnerPair: isWinnerPair,
              ),
              if (index != pair.players.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.sm),
            _PairTotalPill(pairScore: pair.pairScore, isLoserPair: isLoserPair),
          ],
        ),
      ),
    );
  }
}

class _PairPlayerRow extends StatelessWidget {
  const _PairPlayerRow({
    required this.player,
    required this.score,
    required this.safeName,
    required this.isWinnerPair,
  });

  final PlayerConfig player;
  final int score;
  final String Function(PlayerConfig player) safeName;
  final bool isWinnerPair;

  @override
  Widget build(BuildContext context) {
    final scoreGradient = isWinnerPair
        ? AppColors.winnerGradientTopBottom
        : const [Color(0xFFFFFFFF), Color(0xFFF2F3F6)];

    final scoreTextColor = isWinnerPair
        ? const Color(0xFF8A6700)
        : const Color(0xFF4D586D);

    return PremiumGlassSurface(
      height: 72,
      borderRadius: BorderRadius.circular(26),
      gradientColors: [Colors.transparent, Colors.transparent],
      borderColor: Colors.white.withValues(alpha: 0.18),
      innerBorderColor: Colors.white.withValues(alpha: 0.04),
      topHighlightOpacity: 0.12,
      bottomShadeOpacity: 0.16,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isWinnerPair ? null : const Color(0xFFE94494),
              gradient: isWinnerPair
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: AppColors.winnerGradientTopBottom,
                    )
                  : null,
            ),
            child: Text(
              '${player.id}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              safeName(player),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          _ScorePill(
            score: score,
            textColor: scoreTextColor,
            gradient: scoreGradient,
            height: 34,
            iconSize: 18,
            horizontalPadding: 12,
            fontSize: 26 * 0.56,
          ),
        ],
      ),
    );
  }
}

class _PairTotalPill extends StatelessWidget {
  const _PairTotalPill({required this.pairScore, required this.isLoserPair});

  final int pairScore;
  final bool isLoserPair;

  @override
  Widget build(BuildContext context) {
    final gradient = isLoserPair
        ? const [
            Color.fromARGB(255, 241, 63, 47),
            Color.fromARGB(255, 239, 30, 19),
          ]
        : AppColors.winnerGradientTopBottom;
    final textColor = Colors.white;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradient,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Puntaje de pareja',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor.withValues(alpha: 0.98),
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            pairScore >= 0 ? '+$pairScore' : '$pairScore',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 30 * 0.58,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
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

class _LoserChip extends StatelessWidget {
  const _LoserChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 68),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 245, 59, 53),
            Color.fromARGB(255, 234, 37, 26),
          ],
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({
    required this.score,
    required this.textColor,
    required this.gradient,
    this.height = 42,
    this.iconSize = 22,
    this.horizontalPadding = 14,
    this.fontSize = 17,
  });

  final int score;
  final Color textColor;
  final List<Color> gradient;
  final double height;
  final double iconSize;
  final double horizontalPadding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradient,
        ),
      ),
      child: Row(
        children: [
          Text(
            score >= 0 ? '+$score' : '$score',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/logo-icon-start-points.png',
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _FinalHeaderButton extends StatelessWidget {
  const _FinalHeaderButton({required this.accent, required this.onTap});

  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bright = Color.lerp(accent, Colors.white, 0.35)!;
    final dark = Color.lerp(accent, const Color(0xFF120B2D), 0.78)!;

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
                  bright.withValues(alpha: 0.18),
                  dark.withValues(alpha: 0.5),
                ],
              ),
              border: Border.all(
                color: accent.withValues(alpha: 0.54),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.chevron_left_rounded,
                size: 32,
                color: accent.withValues(alpha: 0.95),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RankedPlayer {
  const _RankedPlayer({required this.player, required this.score});

  final PlayerConfig player;
  final int score;
}

class _PairScoreSummary {
  const _PairScoreSummary({
    required this.pairNumber,
    required this.players,
    required this.pairScore,
  });

  final int pairNumber;
  final List<PlayerConfig> players;
  final int pairScore;
}
