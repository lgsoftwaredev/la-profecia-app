import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_3d_pill_button.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../../../player_setup/presentation/widgets/header_circle_button.dart';
import '../../../player_setup/presentation/widgets/level_card_frame.dart';
import '../../../player_setup/presentation/widgets/premium_glass_surface.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../pages/final_group_challenge_page.dart';
import '../pages/final_prophecy_challenge_page.dart';

enum _PunishmentDecision { prophecy, group }

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
  _PunishmentDecision? _selectedDecision;
  var _openingPunishment = false;

  _ModePalette get _palette => _ModePalette.fromMode(widget.submission.mode);

  List<PlayerConfig> get _players {
    final named = widget.submission.players.where((player) => player.name.trim().isNotEmpty).toList(growable: false);
    return named.isNotEmpty ? named : widget.submission.players;
  }

  int _scoreFor(int playerId) => widget.scoresByPlayerId[playerId] ?? 0;

  List<_RankedPlayer> get _rankedPlayers {
    final ranked = _players
        .map((player) => _RankedPlayer(player: player, score: _scoreFor(player.id)))
        .toList(growable: false);

    ranked.sort((left, right) {
      final byScore = right.score.compareTo(left.score);
      if (byScore != 0) {
        return byScore;
      }
      return left.player.id.compareTo(right.player.id);
    });
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

  bool get _showPairRanking => widget.submission.mode.isCouples && _pairs.length > 1;

  List<_PairScoreSummary> get _pairSummaries {
    final summaries = <_PairScoreSummary>[];
    for (var index = 0; index < _pairs.length; index++) {
      final pairPlayers = _pairs[index];
      final pairScore = pairPlayers.map((player) => _scoreFor(player.id)).fold<int>(0, (sum, score) => sum + score);
      summaries.add(_PairScoreSummary(pairNumber: index + 1, players: pairPlayers, pairScore: pairScore));
    }
    return summaries;
  }

  _PairScoreSummary? get _winnerPairSummary {
    if (_pairSummaries.isEmpty) {
      return null;
    }
    var winner = _pairSummaries.first;
    for (final pair in _pairSummaries.skip(1)) {
      if (pair.pairScore > winner.pairScore ||
          (pair.pairScore == winner.pairScore && pair.pairNumber < winner.pairNumber)) {
        winner = pair;
      }
    }
    return winner;
  }

  _PairScoreSummary? get _loserPairSummary {
    if (_pairSummaries.isEmpty) {
      return null;
    }
    var loser = _pairSummaries.first;
    for (final pair in _pairSummaries.skip(1)) {
      if (pair.pairScore < loser.pairScore ||
          (pair.pairScore == loser.pairScore && pair.pairNumber < loser.pairNumber)) {
        loser = pair;
      }
    }
    return loser;
  }

  String _safeName(PlayerConfig player) {
    final trimmed = player.name.trim();
    return trimmed.isEmpty ? 'Jugador ${player.id}' : trimmed;
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
  }

  Future<void> _openPunishmentPage(String punishedLabel) async {
    if (!mounted || _selectedDecision == null || _openingPunishment) {
      return;
    }

    setState(() {
      _openingPunishment = true;
    });

    try {
      final decision = _selectedDecision;
      if (decision == _PunishmentDecision.prophecy) {
        if (widget.onProphecyChallengeTap != null) {
          widget.onProphecyChallengeTap!.call();
          return;
        }
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FinalProphecyChallengePage(submission: widget.submission, punishedLabel: punishedLabel),
          ),
        );
        return;
      }

      if (widget.onGroupDecisionTap != null) {
        widget.onGroupDecisionTap!.call();
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FinalGroupChallengePage(submission: widget.submission, punishedLabel: punishedLabel),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _openingPunishment = false;
        });
      }
    }
  }

  _OutcomeSummary _winnerSummary(List<_RankedPlayer> rankedPlayers) {
    if (_showPairRanking) {
      final pair = _winnerPairSummary;
      if (pair == null) {
        return const _OutcomeSummary.empty(roleLabel: 'Ganador');
      }
      final name = 'Pareja ${pair.pairNumber}';
      return _OutcomeSummary(
        roleLabel: 'Ganador',
        name: name,
        score: pair.pairScore,
        detail: 'Bien jugado, la rompieron!',
        primaryAvatarAssetPath: pair.players.isNotEmpty ? pair.players.first.avatarAssetPath : null,
        secondaryAvatarAssetPath: pair.players.length > 1 ? pair.players[1].avatarAssetPath : null,
      );
    }

    if (rankedPlayers.isEmpty) {
      return const _OutcomeSummary.empty(roleLabel: 'Ganador');
    }

    final winner = rankedPlayers.first;
    return _OutcomeSummary(
      roleLabel: 'Ganador',
      name: _safeName(winner.player),
      score: winner.score,
      detail: 'Bien jugado, la rompiste',
      primaryAvatarAssetPath: winner.player.avatarAssetPath,
    );
  }

  _OutcomeSummary _loserSummary(List<_RankedPlayer> rankedPlayers) {
    if (_showPairRanking) {
      final pair = _loserPairSummary;
      if (pair == null) {
        return const _OutcomeSummary.empty(roleLabel: 'Perdedor');
      }
      final name = 'Pareja ${pair.pairNumber}';
      return _OutcomeSummary(
        roleLabel: 'Perdedor',
        name: name,
        score: pair.pairScore,
        detail: 'Les falto meterle más...',
        primaryAvatarAssetPath: pair.players.isNotEmpty ? pair.players.first.avatarAssetPath : null,
        secondaryAvatarAssetPath: pair.players.length > 1 ? pair.players[1].avatarAssetPath : null,
      );
    }

    if (rankedPlayers.isEmpty) {
      return const _OutcomeSummary.empty(roleLabel: 'Perdedor');
    }

    final loser = rankedPlayers.last;
    return _OutcomeSummary(
      roleLabel: 'Perdedor',
      name: _safeName(loser.player),
      score: loser.score,
      detail: 'Te faltó meterle más',
      primaryAvatarAssetPath: loser.player.avatarAssetPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rankedPlayers = _rankedPlayers;
    final pairSummaries = _pairSummaries;

    final loserLabel = _showPairRanking
        ? 'Pareja ${_loserPairSummary?.pairNumber ?? 1}'
        : (rankedPlayers.isNotEmpty ? _safeName(rankedPlayers.last.player) : 'Jugador 1');

    final targetLabel = _showPairRanking ? 'PAREJA PERDEDORA' : loserLabel.toUpperCase();

    final winnerSummary = _winnerSummary(rankedPlayers);
    final loserSummary = _loserSummary(rankedPlayers);

    final ctaEnabled = _selectedDecision != null && !_openingPunishment;
    final ctaGradient = ctaEnabled ? _palette.enabledButtonGradient : const [Color(0xFF37404D), Color(0xFF1E232D)];

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_palette.backgroundAsset, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0x6B050316), const Color(0xFF06020F).withValues(alpha: 0.97)],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.15),
                radius: 1.05,
                colors: [
                  _palette.glowCenter.withValues(alpha: 0.50),
                  _palette.glowEdge.withValues(alpha: 0.20),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.42, 0.86],
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
                  Row(
                    children: [
                      HeaderCircleButton(
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 29),
                      ),
                      Expanded(
                        child: Center(child: Image.asset(_palette.headerLogoAsset, width: 124, fit: BoxFit.contain)),
                      ),
                      HeaderCircleButton(
                        onTap: _openSettings,
                        child: Image.asset(
                          'assets/menu-logo-icon-settings.png',
                          width: 21,
                          height: 21,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 26),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          Image.asset(_palette.judgmentHeroAsset, width: 182, fit: BoxFit.contain),
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            height: 34,
                            width: 110,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: const Color(0xFF0E1725).withValues(alpha: 0.82),
                              border: Border.all(color: _palette.modeAccent.withValues(alpha: 0.40)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '¡Se acabó!',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: _palette.modeAccent,
                                fontWeight: FontWeight.w500,
                                fontSize: 24 * 0.52,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Juicio final',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 52 * 0.70,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'La partida ha terminado. Aquí está el resultado.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.80),
                              fontWeight: FontWeight.w400,
                              fontSize: 27 * 0.52,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl * 1.5),
                          _OutcomeCardsSection(winner: winnerSummary, loser: loserSummary, palette: _palette),
                          const SizedBox(height: AppSpacing.lg),
                          _ScoreBoardContainer(
                            palette: _palette,
                            showPairRanking: _showPairRanking,
                            rankedPlayers: rankedPlayers,
                            pairSummaries: pairSummaries,
                            winnerPairNumber: _winnerPairSummary?.pairNumber,
                            loserPairNumber: _loserPairSummary?.pairNumber,
                            scoreFor: _scoreFor,
                            safeName: _safeName,
                          ),
                          const SizedBox(height: 20),
                          Image.asset('assets/divider-premium.png', width: 210, fit: BoxFit.contain),
                          const SizedBox(height: 14),
                          Text(
                            '¿Quién aplicará el castigo?',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w600,
                              fontSize: 42 * 0.58,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Elige quién decidirá el reto para',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontWeight: FontWeight.w400,
                              fontSize: 25 * 0.52,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            targetLabel,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFFFF4641),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              fontSize: 27 * 0.52,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: _PunishmentChoiceCard(
                                  title: 'La Profecía',
                                  prefixLabel: 'Reto de',
                                  description: 'El reto que tenemos preparado para ti.',
                                  iconAsset: _palette.prophecyChoiceAsset,
                                  borderColor: _palette.modeAccent,
                                  isSelected: _selectedDecision == _PunishmentDecision.prophecy,
                                  onTap: () {
                                    setState(() {
                                      _selectedDecision = _PunishmentDecision.prophecy;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _PunishmentChoiceCard(
                                  title: 'El grupo',
                                  prefixLabel: 'Elige el reto del',
                                  description: 'El reto que el grupo decida, no hay límites...',
                                  iconAsset: 'assets/logo-icon-group-judgment-final.png',
                                  borderColor: const Color(0xFFE8B23C),
                                  isSelected: _selectedDecision == _PunishmentDecision.group,
                                  onTap: () {
                                    setState(() {
                                      _selectedDecision = _PunishmentDecision.group;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          App3dPillButton(
                            label: 'Ir al castigo',
                            color: ctaGradient.first,
                            gradientColors: ctaGradient,
                            height: 60,
                            depth: 4,
                            borderRadius: 999,
                            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: ctaEnabled ? Colors.white : Colors.white.withValues(alpha: 0.38),
                              fontWeight: FontWeight.w700,
                              fontSize: 34 * 0.56,
                            ),
                            onTap: ctaEnabled ? () => _openPunishmentPage(loserLabel) : null,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Debes seleccionar quien aplicará el castigo',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.54), fontSize: 12),
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

class _OutcomeCardsSection extends StatelessWidget {
  const _OutcomeCardsSection({required this.winner, required this.loser, required this.palette});

  final _OutcomeSummary winner;
  final _OutcomeSummary loser;
  final _ModePalette palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = AppSpacing.sm;
        final width = (constraints.maxWidth - spacing) / 2;
        return Row(
          children: [
            _OutcomeCard(
              summary: winner,
              isWinner: true,
              width: width,
              borderColor: const Color(0xFFF5D359),
              baseTopColor: const Color(0xFF2E2A13),
              baseBottomColor: const Color(0xFF0D0A11),
              palette: palette,
            ),
            const SizedBox(width: AppSpacing.sm),
            _OutcomeCard(
              summary: loser,
              isWinner: false,
              width: width,
              borderColor: const Color(0xFFE53D37),
              baseTopColor: const Color(0xFF2C1515),
              baseBottomColor: const Color(0xFF0F090B),
              palette: palette,
            ),
          ],
        );
      },
    );
  }
}

class _OutcomeCard extends StatelessWidget {
  const _OutcomeCard({
    required this.summary,
    required this.isWinner,
    required this.width,
    required this.borderColor,
    required this.baseTopColor,
    required this.baseBottomColor,
    required this.palette,
  });

  final _OutcomeSummary summary;
  final bool isWinner;
  final double width;
  final Color borderColor;
  final Color baseTopColor;
  final Color baseBottomColor;
  final _ModePalette palette;

  @override
  Widget build(BuildContext context) {
    var frameHeight = isWinner ? 124.0 : 112.0;
    var frameWidth = isWinner ? (width * 1.10) : width * 0.90;
    return SizedBox(
      width: frameWidth,
      height: frameHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          VerticalLevelCardFrame(
            width: frameWidth,
            borderColor: borderColor,
            baseTopColor: baseTopColor,
            baseBottomColor: baseBottomColor,
            bottomTintStrong: borderColor.withValues(alpha: 0.23),
            bottomTintSoft: borderColor.withValues(alpha: 0.08),
            topLineColor: borderColor,
            topShadowStrongAlpha: 0.26,
            topShadowSoftAlpha: 0.12,
            borderRadius: 17,
            contentPadding: const EdgeInsets.fromLTRB(10, 20, 10, 9),
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    _OutcomeAvatarStack(
                      primaryAsset: summary.primaryAvatarAssetPath,
                      secondaryAsset: summary.secondaryAvatarAssetPath,
                      borderColor: borderColor,
                      isWinner: isWinner,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        summary.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.96),
                          fontWeight: FontWeight.w700,
                          fontSize: isWinner ? 17 : 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Column(
                      children: [
                        Text(
                          '${summary.score}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isWinner ? const Color(0xFFF6D35A) : const Color(0xFFFF4C42),
                            fontWeight: FontWeight.w700,
                            fontSize: isWinner ? 17 : 15,
                          ),
                        ),
                        Text(
                          'Puntos',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.black.withValues(alpha: 0.26),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    summary.detail,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.70),
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -14,
            left: 0,
            right: 0,
            child: Center(
              child: _OutcomeRoleChip(
                label: summary.roleLabel,
                accent: isWinner ? const Color(0xFFF5D359) : const Color(0xFFE53D37),
                showCrown: isWinner,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutcomeRoleChip extends StatelessWidget {
  const _OutcomeRoleChip({required this.label, required this.accent, this.showCrown = false});

  final String label;
  final Color accent;
  final bool showCrown;

  @override
  Widget build(BuildContext context) {
    final topColor = Color.lerp(accent, const Color(0xFF315B7E), 0.72)!;
    final roleTextColor = showCrown ? const Color(0xFFF6D35A) : const Color(0xFFFFD9D9);

    return SizedBox(
      height: showCrown ? 30 : 22,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 22,
            width: 100,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [topColor.withValues(alpha: 0.94), const Color(0xFF14263A).withValues(alpha: 0.94)],
              ),
              border: Border.all(color: accent.withValues(alpha: 0.78), width: 1.0),
              boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.30), blurRadius: 14, spreadRadius: 0.4)],
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: roleTextColor,
                fontWeight: FontWeight.w700,
                fontSize: showCrown ? 14 : 12,
              ),
            ),
          ),
          if (showCrown)
            Positioned(
              top: -14,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset('assets/logo-icon-premium-corona.png', width: 22, height: 22, fit: BoxFit.contain),
              ),
            ),
        ],
      ),
    );
  }
}

class _OutcomeAvatarStack extends StatelessWidget {
  const _OutcomeAvatarStack({
    required this.primaryAsset,
    required this.secondaryAsset,
    required this.borderColor,
    required this.isWinner,
  });

  final String? primaryAsset;
  final String? secondaryAsset;
  final Color borderColor;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    if (primaryAsset == null) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.5),
        ),
      );
    }

    return SizedBox(
      width: secondaryAsset == null ? 34 : 52,
      height: isWinner ? 34 : 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _AvatarCircle(assetPath: primaryAsset!, borderColor: borderColor, size: isWinner ? 34 : 30),
          if (secondaryAsset != null)
            Positioned(
              left: 18,
              child: _AvatarCircle(
                assetPath: secondaryAsset!,
                borderColor: borderColor.withValues(alpha: 0.72),
                size: isWinner ? 34 : 30,
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.assetPath, required this.borderColor, this.size = 34});

  final String assetPath;
  final Color borderColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: ClipOval(child: Image.asset(assetPath, fit: BoxFit.cover)),
    );
  }
}

class _ScoreBoardContainer extends StatelessWidget {
  const _ScoreBoardContainer({
    required this.palette,
    required this.showPairRanking,
    required this.rankedPlayers,
    required this.pairSummaries,
    required this.winnerPairNumber,
    required this.loserPairNumber,
    required this.scoreFor,
    required this.safeName,
  });

  final _ModePalette palette;
  final bool showPairRanking;
  final List<_RankedPlayer> rankedPlayers;
  final List<_PairScoreSummary> pairSummaries;
  final int? winnerPairNumber;
  final int? loserPairNumber;
  final int Function(int playerId) scoreFor;
  final String Function(PlayerConfig player) safeName;

  double _tableTitleHeight(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return 20 * scale;
  }

  double _pairCardHeightFor(BuildContext context, int playerCount) {
    final safeCount = playerCount <= 0 ? 1 : playerCount;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final pairTitleHeight = 18 * scale;
    return pairTitleHeight + 92 + (50 * safeCount);
  }

  double _containerHeight(BuildContext context) {
    final verticalPadding = AppSpacing.lg * 2.5;
    final titleBlockHeight = _tableTitleHeight(context) + AppSpacing.md;
    if (showPairRanking) {
      final cardsHeight = pairSummaries.fold<double>(
        0,
        (sum, pair) => sum + _pairCardHeightFor(context, pair.players.length),
      );
      final cardsSpacing = pairSummaries.length <= 1 ? 0 : (pairSummaries.length - 1) * AppSpacing.md;
      return verticalPadding + titleBlockHeight + cardsHeight + cardsSpacing;
    }

    final rowsCount = rankedPlayers.isEmpty ? 1 : rankedPlayers.length;
    final rowsHeight = (rowsCount * 66) + ((rowsCount - 1) * AppSpacing.sm);
    return verticalPadding + titleBlockHeight + rowsHeight;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _containerHeight(context),
      child: PremiumGlassSurface(
        borderRadius: BorderRadius.circular(28),
        gradientColors: const [Color(0x4C212839), Color(0xA50A0E18)],
        borderColor: palette.modeAccent.withValues(alpha: 0.18),
        innerBorderColor: Colors.white.withValues(alpha: 0.06),
        topHighlightOpacity: 0.14,
        bottomShadeOpacity: 0.24,
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tabla de puntajes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.94),
                fontWeight: FontWeight.w600,
                fontSize: 37 * 0.53,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (showPairRanking)
              _PairRankingList(
                pairSummaries: pairSummaries,
                winnerPairNumber: winnerPairNumber,
                loserPairNumber: loserPairNumber,
                scoreFor: scoreFor,
                safeName: safeName,
              )
            else
              _PlayerRankingRows(rankedPlayers: rankedPlayers, safeName: safeName),
          ],
        ),
      ),
    );
  }
}

class _PlayerRankingRows extends StatelessWidget {
  const _PlayerRankingRows({required this.rankedPlayers, required this.safeName});

  final List<_RankedPlayer> rankedPlayers;
  final String Function(PlayerConfig player) safeName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < rankedPlayers.length; index++) ...[
          _PlayerRankingRow(
            rank: index + 1,
            player: rankedPlayers[index].player,
            score: rankedPlayers[index].score,
            name: safeName(rankedPlayers[index].player),
            isWinner: index == 0,
            isLoser: index == rankedPlayers.length - 1,
          ),
          if (index != rankedPlayers.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _PlayerRankingRow extends StatelessWidget {
  const _PlayerRankingRow({
    required this.rank,
    required this.player,
    required this.score,
    required this.name,
    required this.isWinner,
    required this.isLoser,
  });

  final int rank;
  final PlayerConfig player;
  final int score;
  final String name;
  final bool isWinner;
  final bool isLoser;

  @override
  Widget build(BuildContext context) {
    final borderColor = isWinner
        ? const Color(0xFFF5D359)
        : (isLoser ? const Color(0xFFFF4E4A) : Colors.white.withValues(alpha: 0.28));

    final rankColor = isWinner
        ? const Color(0xFFF8BE2A)
        : (isLoser ? const Color(0xFFE63F35) : const Color(0xFF4AA5FF));

    final pointsGradient = isWinner
        ? AppColors.winnerGradientTopBottom
        : (isLoser ? const [Color(0xFFF14A40), Color(0xFFCC2F28)] : const [Color(0xFFFFFFFF), Color(0xFFF2F3F6)]);

    final scoreTextColor = isWinner ? const Color(0xFF8A6700) : (isLoser ? Colors.white : const Color(0xFF4D586D));

    return PremiumGlassSurface(
      height: 66,
      borderRadius: BorderRadius.circular(999),
      gradientColors: const [Color(0x7A2A3144), Color(0x66222937)],
      borderColor: borderColor,
      innerBorderColor: borderColor.withValues(alpha: isWinner || isLoser ? 1 : 0.18),
      topHighlightOpacity: 0.12,
      bottomShadeOpacity: 0.16,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: rankColor),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20 * 0.70),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: ClipOval(child: Image.asset(player.avatarAssetPath, fit: BoxFit.cover)),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.96),
                      fontWeight: FontWeight.w700,
                      fontSize: 33 * 0.52,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _ScoreTokenPill(score: score, gradient: pointsGradient, textColor: scoreTextColor),
        ],
      ),
    );
  }
}

class _PairRankingList extends StatelessWidget {
  const _PairRankingList({
    required this.pairSummaries,
    required this.winnerPairNumber,
    required this.loserPairNumber,
    required this.scoreFor,
    required this.safeName,
  });

  final List<_PairScoreSummary> pairSummaries;
  final int? winnerPairNumber;
  final int? loserPairNumber;
  final int Function(int playerId) scoreFor;
  final String Function(PlayerConfig player) safeName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < pairSummaries.length; index++) ...[
          _PairRankingCard(
            pair: pairSummaries[index],
            scoreFor: scoreFor,
            safeName: safeName,
            isWinnerPair: pairSummaries[index].pairNumber == winnerPairNumber,
            isLoserPair: pairSummaries[index].pairNumber == loserPairNumber,
          ),
          if (index != pairSummaries.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _PairRankingCard extends StatelessWidget {
  const _PairRankingCard({
    required this.pair,
    required this.scoreFor,
    required this.safeName,
    required this.isWinnerPair,
    required this.isLoserPair,
  });

  final _PairScoreSummary pair;
  final int Function(int playerId) scoreFor;
  final String Function(PlayerConfig player) safeName;
  final bool isWinnerPair;
  final bool isLoserPair;

  @override
  Widget build(BuildContext context) {
    final playersCount = pair.players.isEmpty ? 1 : pair.players.length;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final pairTitleHeight = 18 * scale;
    final cardHeight = pairTitleHeight + 92 + (50 * playersCount);
    final colorWinner = Color(0xFF84FF8D);
    final colorLoser = Color(0xFFF14A40);
    final borderColor = isWinnerPair ? colorWinner : colorLoser;

    final totalGradient = [borderColor.withValues(alpha: 0.14), borderColor.withValues(alpha: 0.14)];

    return PremiumGlassSurface(
      height: cardHeight,
      borderRadius: BorderRadius.circular(18),
      gradientColors: const [Color(0x7A2A3144), Color(0x61222937)],
      borderColor: Colors.white.withValues(alpha: 0.28),
      innerBorderColor: Colors.white.withValues(alpha: 0.18),
      topHighlightOpacity: 0.12,
      bottomShadeOpacity: 0.16,
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
      child: Column(
        children: [
          Text(
            'Pareja ${pair.pairNumber}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var index = 0; index < pair.players.length; index++) ...[
            _PairPlayerScoreRow(
              rank: pair.players[index].id,
              player: pair.players[index],
              name: safeName(pair.players[index]),
              score: scoreFor(pair.players[index].id),
            ),
            if (index != pair.players.length - 1) const SizedBox(height: AppSpacing.xs),
          ],
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: totalGradient),
              border: Border.all(color: borderColor.withValues(alpha: 0.20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Puntaje de pareja',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: borderColor.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  '${pair.pairScore}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: borderColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PairPlayerScoreRow extends StatelessWidget {
  const _PairPlayerScoreRow({required this.rank, required this.player, required this.name, required this.score});

  final int rank;
  final PlayerConfig player;
  final String name;
  final int score;

  @override
  Widget build(BuildContext context) {
    return PremiumGlassSurface(
      height: 42,
      borderRadius: BorderRadius.circular(999),
      gradientColors: const [Color(0x60353D4E), Color(0x532A3041)],
      borderColor: Colors.white.withValues(alpha: 0.18),
      innerBorderColor: Colors.white.withValues(alpha: 0.10),
      topHighlightOpacity: 0.08,
      bottomShadeOpacity: 0.14,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE3477D)),
            child: Text(
              '$rank',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
            ),
            child: ClipOval(child: Image.asset(player.avatarAssetPath, fit: BoxFit.cover)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.94),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          _ScoreTokenPill(
            score: score,
            gradient: const [Color(0xFFFFFFFF), Color(0xFFF2F3F6)],
            textColor: const Color(0xFF4D586D),
            height: 30,
            iconSize: 14,
            horizontalPadding: 10,
            fontSize: 14,
          ),
        ],
      ),
    );
  }
}

class _ScoreTokenPill extends StatelessWidget {
  const _ScoreTokenPill({
    required this.score,
    required this.gradient,
    required this.textColor,
    this.height = 36,
    this.iconSize = 18,
    this.horizontalPadding = 12,
    this.fontSize = 18,
  });

  final int score;
  final List<Color> gradient;
  final Color textColor;
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
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: gradient),
      ),
      child: Row(
        children: [
          Text(
            '$score',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.w700, fontSize: fontSize),
          ),
          const SizedBox(width: 6),
          Image.asset('assets/logo-icon-start-points.png', width: iconSize, height: iconSize, fit: BoxFit.contain),
        ],
      ),
    );
  }
}

class _PunishmentChoiceCard extends StatelessWidget {
  const _PunishmentChoiceCard({
    required this.title,
    required this.prefixLabel,
    required this.description,
    required this.iconAsset,
    required this.borderColor,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String prefixLabel;
  final String description;
  final String iconAsset;
  final Color borderColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconSize = isSelected ? 42.0 : 38.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: PremiumGlassSurface(
          height: isSelected ? 170 : 160,
          borderRadius: BorderRadius.circular(16),
          gradientColors: const [Color(0x742A3144), Color(0x5B202536)],
          borderColor: borderColor.withValues(alpha: isSelected ? 0.88 : 0.42),
          innerBorderColor: borderColor.withValues(alpha: isSelected ? 0.24 : 0.10),
          topHighlightOpacity: isSelected ? 0.20 : 0.12,
          topHighlightColor: borderColor,
          bottomShadeOpacity: 0.18,
          padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const SizedBox(width: AppSpacing.xxl),
                  const Spacer(),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    width: iconSize,
                    height: iconSize,
                    child: Image.asset(iconAsset, fit: BoxFit.contain),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Image.asset(
                      'assets/logo-icon-checked.png',
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                      color: Colors.white.withValues(alpha: 0.97),
                    )
                  else
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.78), width: 2.2),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                prefixLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.96),
                  fontWeight: FontWeight.w700,
                  fontSize: 35 * 0.52,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: Colors.black.withValues(alpha: 0.22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: Text(
                  description,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.67),
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModePalette {
  const _ModePalette({
    required this.backgroundAsset,
    required this.headerLogoAsset,
    required this.judgmentHeroAsset,
    required this.prophecyChoiceAsset,
    required this.modeAccent,
    required this.glowCenter,
    required this.glowEdge,
    required this.enabledButtonGradient,
  });

  final String backgroundAsset;
  final String headerLogoAsset;
  final String judgmentHeroAsset;
  final String prophecyChoiceAsset;
  final Color modeAccent;
  final Color glowCenter;
  final Color glowEdge;
  final List<Color> enabledButtonGradient;

  factory _ModePalette.fromMode(GameMode mode) {
    if (mode.isFriends) {
      return const _ModePalette(
        backgroundAsset: 'assets/background-setup-friends-mode.png',
        headerLogoAsset: 'assets/logo-simple-blue.png',
        judgmentHeroAsset: 'assets/logo-icon-judgment-final-mode-friends.png',
        prophecyChoiceAsset: 'assets/logo-icon-prophecy-judgment-final-mode-friends.png',
        modeAccent: Color(0xFF39A8FF),
        glowCenter: Color(0xFF214E84),
        glowEdge: Color(0xFF113056),
        enabledButtonGradient: [Color(0xFF48B3FF), Color(0xFF1D5DDA)],
      );
    }

    return const _ModePalette(
      backgroundAsset: 'assets/background-setup-couple-mode.png',
      headerLogoAsset: 'assets/logo-simple-signature.png',
      judgmentHeroAsset: 'assets/logo-icon-judgment-final-mode-couple.png',
      prophecyChoiceAsset: 'assets/logo-icon-prophecy-judgment-final-mode-couple.png',
      modeAccent: Color(0xFFE95AA5),
      glowCenter: Color(0xFF5A1F55),
      glowEdge: Color(0xFF31153C),
      enabledButtonGradient: [Color(0xFFF574B9), Color(0xFFD93D88)],
    );
  }
}

class _RankedPlayer {
  const _RankedPlayer({required this.player, required this.score});

  final PlayerConfig player;
  final int score;
}

class _PairScoreSummary {
  const _PairScoreSummary({required this.pairNumber, required this.players, required this.pairScore});

  final int pairNumber;
  final List<PlayerConfig> players;
  final int pairScore;
}

class _OutcomeSummary {
  const _OutcomeSummary({
    required this.roleLabel,
    required this.name,
    required this.score,
    required this.detail,
    required this.primaryAvatarAssetPath,
    this.secondaryAvatarAssetPath,
  });

  const _OutcomeSummary.empty({required this.roleLabel})
    : name = '---',
      score = 0,
      detail = 'Sin datos de partida',
      primaryAvatarAssetPath = null,
      secondaryAvatarAssetPath = null;

  final String roleLabel;
  final String name;
  final int score;
  final String detail;
  final String? primaryAvatarAssetPath;
  final String? secondaryAvatarAssetPath;
}
