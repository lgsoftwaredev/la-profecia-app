import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../match_play/domain/entities/game_prompt.dart';
import '../../../match_play/domain/entities/match_level.dart';
import '../../../match_play/domain/entities/truth_or_dare_option.dart';
import '../../../match_play/presentation/pages/truth_or_dare_turn_page.dart';
import '../../../match_play/presentation/providers/match_providers.dart';
import '../../domain/entities/game_setup_models.dart';
import '../widgets/level_card_frame.dart';
import '../widgets/start_points_roulette_wheel.dart';

class StartPointsPage extends ConsumerStatefulWidget {
  const StartPointsPage({
    required this.submission,
    required this.selectedOption,
    super.key,
  });

  final GameSetupSubmission submission;
  final TruthOrDareOption selectedOption;

  @override
  ConsumerState<StartPointsPage> createState() => _StartPointsPageState();
}

class _StartPointsPageState extends ConsumerState<StartPointsPage> {
  static const _order = [
    GameStyleTheme.cielo,
    GameStyleTheme.tierra,
    GameStyleTheme.infierno,
    GameStyleTheme.inframundo,
  ];

  late GameStyleTheme _selectedTheme = _initialTheme(
    widget.submission.selectedTheme,
  );
  var _didBootstrapMatch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didBootstrapMatch) {
        return;
      }
      _didBootstrapMatch = true;
      _bootstrapMatch();
    });
  }

  Future<void> _bootstrapMatch() async {
    final controller = ref.read(matchControllerProvider);
    if (!controller.hasActiveMatch) {
      await controller.createMatch(widget.submission);
    }
    ref.read(activeSetupSubmissionProvider.notifier).state = widget.submission;
    if (!mounted) {
      return;
    }
    final available = controller.availableLevels;
    if (available.isNotEmpty &&
        !available.contains(_selectedTheme.toMatchLevel)) {
      _selectedTheme = available.first.toGameStyleTheme;
      setState(() {});
    }
  }

  static GameStyleTheme _initialTheme(GameStyleTheme input) {
    if (input == GameStyleTheme.infierno ||
        input == GameStyleTheme.inframundo) {
      return GameStyleTheme.cielo;
    }
    return input;
  }

  String get _backgroundAsset => widget.submission.mode.isFriends
      ? 'assets/background-setup-friends-mode.png'
      : 'assets/background-setup-couple-mode.png';

  bool _isLocked(GameStyleTheme theme, List<MatchLevel> availableLevels) {
    final level = theme.toMatchLevel;
    return !availableLevels.contains(level);
  }

  int _pointsFor(GameStyleTheme theme) => theme.toMatchLevel.points;

  Future<void> _openTurnPage(GameStyleTheme selectedTheme) async {
    final submission = GameSetupSubmission(
      mode: widget.submission.mode,
      players: widget.submission.players,
      pairs: widget.submission.pairs,
      selectedTheme: selectedTheme,
    );
    ref.read(activeSetupSubmissionProvider.notifier).state = submission;

    final kind = widget.selectedOption == TruthOrDareOption.verdad
        ? MatchPromptKind.question
        : MatchPromptKind.challenge;
    final controller = ref.read(matchControllerProvider);
    final turn = await controller.startTurn(
      kind: kind,
      preferredLevel: selectedTheme.toMatchLevel,
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
          option: widget.selectedOption,
          round: turn.roundNumber,
          points: points,
          initialTurn: turn,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableLevels = ref.watch(matchAvailableLevelsProvider);
    final scoresByPlayerId = ref.watch(matchScoresProvider);

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
                  const Color(0x73050316),
                  const Color(0xFF070712).withValues(alpha: 0.94),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: SizedBox(
                    height: 96,
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              'assets/logo-+18.png',
                              width: 128,
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
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      170,
                    ),
                    child: Column(
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Iniciemos la '),
                              TextSpan(
                                text: 'profecía',
                                style: const TextStyle(
                                  color: Color(0xFFE63D86),
                                ),
                              ),
                            ],
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontSize: 41 * 0.65,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Esto se pondrá bueeeeno...',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _RouletteSection(
                          selectedTheme: _selectedTheme,
                          availableThemes: availableLevels
                              .map((level) => level.toGameStyleTheme)
                              .toList(growable: false),
                          selectedPoints: _pointsFor(_selectedTheme),
                          onThemeChanged: (theme) =>
                              setState(() => _selectedTheme = theme),
                          onSpinCompleted: (theme) {
                            _openTurnPage(theme);
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _PlayersPointsSection(
                          submission: widget.submission,
                          scoresByPlayerId: scoresByPlayerId,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Elige tu nivel',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.92),
                                ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        for (final theme in _order) ...[
                          LevelCardFrame(
                            borderColor: theme.accentColor,
                            isSelected: _selectedTheme == theme,
                            enabled: !_isLocked(theme, availableLevels),
                            onTap: () {
                              if (_isLocked(theme, availableLevels)) {
                                return;
                              }
                              setState(() {
                                _selectedTheme = theme;
                              });
                            },
                            height: 74,
                            borderRadius: 20,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            child: Row(
                              children: [
                                _ThemeSquareIcon(theme: theme),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        theme.label,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.2,
                                            ),
                                      ),
                                      Text(
                                        '+${_pointsFor(theme)} puntos',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.82,
                                              ),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isLocked(theme, availableLevels))
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/logo-icon-time-waiting.png',
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '21:00',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                            ),
                                      ),
                                    ],
                                  )
                                else
                                  Image.asset(
                                    'assets/logo-icon-checked.png',
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'INFIERNO E INFRAMUNDO se desbloquearán\ntras la 1ra ronda...',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Colors.white.withValues(alpha: 0.72),
                                height: 1.2,
                              ),
                        ),
                      ],
                    ),
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

class _RouletteSection extends StatelessWidget {
  const _RouletteSection({
    required this.selectedTheme,
    required this.availableThemes,
    required this.selectedPoints,
    required this.onThemeChanged,
    required this.onSpinCompleted,
  });

  final GameStyleTheme selectedTheme;
  final List<GameStyleTheme> availableThemes;
  final int selectedPoints;
  final ValueChanged<GameStyleTheme> onThemeChanged;
  final ValueChanged<GameStyleTheme> onSpinCompleted;

  @override
  Widget build(BuildContext context) {
    final selectedColor = selectedTheme.accentColor;

    return Column(
      children: [
        StartPointsRouletteWheel(
          selectedTheme: selectedTheme,
          availableThemes: availableThemes,
          onThemeChanged: onThemeChanged,
          onSpinCompleted: onSpinCompleted,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          selectedTheme.label,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: selectedColor,
            fontWeight: FontWeight.w700,
            fontSize: 41 * 0.62,
          ),
        ),
        Text(
          '+$selectedPoints puntos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PlayersPointsSection extends StatelessWidget {
  const _PlayersPointsSection({
    required this.submission,
    required this.scoresByPlayerId,
  });

  final GameSetupSubmission submission;
  final Map<int, int> scoresByPlayerId;

  @override
  Widget build(BuildContext context) {
    final visiblePlayers = submission.players
        .where((player) => player.name.trim().isNotEmpty)
        .toList(growable: false);

    final players = visiblePlayers.isEmpty
        ? [
            for (final player in submission.players)
              _ScorePlayer(
                id: player.id,
                name: 'Jugador ${player.id}',
                points: scoresByPlayerId[player.id] ?? 0,
              ),
          ]
        : visiblePlayers
              .map(
                (player) => _ScorePlayer(
                  id: player.id,
                  name: player.name.trim(),
                  points: scoresByPlayerId[player.id] ?? 0,
                ),
              )
              .toList(growable: false);

    if (submission.mode.isCouples) {
      final pairs = submission.pairs.isNotEmpty
          ? [
              for (
                var pairIndex = 0;
                pairIndex < submission.pairs.length;
                pairIndex++
              )
                (
                  title: 'Pareja ${pairIndex + 1}',
                  players: submission.pairs[pairIndex]
                      .map(
                        (player) => _ScorePlayer(
                          id: player.id,
                          name: player.name.trim().isEmpty
                              ? 'Jugador ${player.id}'
                              : player.name.trim(),
                          points: scoresByPlayerId[player.id] ?? 0,
                        ),
                      )
                      .toList(growable: false),
                ),
            ]
          : _buildFallbackPairs(players);

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (var i = 0; i < pairs.length; i++) ...[
              SizedBox(
                width: 210,
                child: _PlayersGroupCard(
                  title: pairs[i].title,
                  players: pairs[i].players,
                  accentColor: const Color(0xFFFF2B97),
                  highlightBorder: i == 0,
                ),
              ),
              if (i != pairs.length - 1) const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jugadores',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 42 * 0.62,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.93),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              for (var i = 0; i < players.length; i++) ...[
                SizedBox(
                  width: 196,
                  child: _PlayerPointsTile(
                    player: players[i],
                    accentColor: const Color(0xFF0787FF),
                  ),
                ),
                if (i != players.length - 1)
                  const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<({String title, List<_ScorePlayer> players})> _buildFallbackPairs(
    List<_ScorePlayer> players,
  ) {
    final pairs = <({String title, List<_ScorePlayer> players})>[];
    for (var i = 0; i < players.length; i += 2) {
      final chunk = players.skip(i).take(2).toList(growable: false);
      pairs.add((title: 'Pareja ${(i ~/ 2) + 1}', players: chunk));
    }
    return pairs;
  }
}

class _PlayersGroupCard extends StatelessWidget {
  const _PlayersGroupCard({
    required this.title,
    required this.players,
    required this.accentColor,
    required this.highlightBorder,
  });

  final String title;
  final List<_ScorePlayer> players;
  final Color accentColor;
  final bool highlightBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xF711131A), Color(0xF305070B)],
        ),
        border: Border.all(
          color: highlightBorder
              ? accentColor.withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.08),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: highlightBorder
                ? accentColor.withValues(alpha: 0.22)
                : Colors.black.withValues(alpha: 0.22),
            blurRadius: 22,
            spreadRadius: 0.3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 42 * 0.62,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.93),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (var i = 0; i < players.length; i++) ...[
            _PlayerPointsTile(player: players[i], accentColor: accentColor),
            if (i != players.length - 1) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _PlayerPointsTile extends StatelessWidget {
  const _PlayerPointsTile({required this.player, required this.accentColor});

  final _ScorePlayer player;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF0C0E14).withValues(alpha: 0.92),
        border: Border.all(color: accentColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.50),
            blurRadius: 18,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor,
            ),
            child: Text(
              '${player.id}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 19,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Image.asset(
                      'assets/logo-icon-start-points.png',
                      width: 14,
                      height: 14,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${player.points} puntos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.84),
                        fontSize: 12.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScorePlayer {
  const _ScorePlayer({
    required this.id,
    required this.name,
    required this.points,
  });

  final int id;
  final String name;
  final int points;
}

class _ThemeSquareIcon extends StatelessWidget {
  const _ThemeSquareIcon({required this.theme});

  final GameStyleTheme theme;

  @override
  Widget build(BuildContext context) {
    if (theme == GameStyleTheme.inframundo) {
      return Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '😈',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 22,
            color: const Color(0xFFC246FF),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final asset = switch (theme) {
      GameStyleTheme.cielo => 'assets/cielo-icon-logo.png',
      GameStyleTheme.tierra => 'assets/tierra-icon-logo.png',
      GameStyleTheme.infierno => 'assets/infierno-icon-logo.png',
      GameStyleTheme.inframundo => 'assets/inframundo-icon-logo.png',
    };

    return Container(
      width: 34,
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }
}

class _HeaderSideButton extends StatelessWidget {
  const _HeaderSideButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 80,
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
                  const Color(0xFF081730).withValues(alpha: 0.72),
                  const Color(0xFF071126).withValues(alpha: 0.58),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF1176E3).withValues(alpha: 0.48),
                width: 1.1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.chevron_left_rounded,
                size: 32,
                color: const Color(0xFF20A5FF).withValues(alpha: 0.95),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
