import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/global_bottom_menu.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../domain/entities/game_setup_models.dart';
import '../controllers/player_setup_controller.dart';
import '../widgets/game_style_card.dart';
import '../widgets/player_name_card.dart';
import '../widgets/player_setup_primary_button.dart';
import '../widgets/setup_count_selector.dart';

class PlayerSetupPage extends StatefulWidget {
  const PlayerSetupPage({required this.mode, this.isPremium = false, this.onStart, super.key});

  final GameMode mode;
  final bool isPremium;
  final ValueChanged<GameSetupSubmission>? onStart;

  @override
  State<PlayerSetupPage> createState() => _PlayerSetupPageState();
}

class _PlayerSetupPageState extends State<PlayerSetupPage> {
  late final PlayerSetupController _controller = PlayerSetupController(mode: widget.mode, isPremium: widget.isPremium);
  final Map<int, TextEditingController> _nameControllers = {};
  var _bottomMenuItem = GlobalBottomMenuItem.home;

  @override
  void initState() {
    super.initState();
    _syncNameControllers(_controller.state.players);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    for (final controller in _nameControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() {
    _syncNameControllers(_controller.state.players);
    if (mounted) {
      setState(() {});
    }
  }

  void _syncNameControllers(List<PlayerConfig> players) {
    final activeIds = players.map((player) => player.id).toSet();
    final removedIds = _nameControllers.keys.where((id) => !activeIds.contains(id)).toList(growable: false);

    for (final id in removedIds) {
      _nameControllers.remove(id)?.dispose();
    }

    for (final player in players) {
      final controller = _nameControllers[player.id];
      if (controller == null) {
        _nameControllers[player.id] = TextEditingController(text: player.name);
        continue;
      }

      if (controller.text != player.name) {
        controller.value = controller.value.copyWith(
          text: player.name,
          selection: TextSelection.collapsed(offset: player.name.length),
          composing: TextRange.empty,
        );
      }
    }
  }

  void _onSubmit() {
    final submission = _controller.submit();
    if (submission == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Completa el nombre de todos los jugadores.')));
      return;
    }

    widget.onStart?.call(submission);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          submission.mode.isFriends
              ? 'Partida lista con ${submission.players.length} jugadores.'
              : 'Partida lista con ${submission.pairs.length} parejas.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final modeAccent = state.mode.isFriends ? const Color.fromARGB(255, 7, 135, 255) : const Color(0xFFE94494);
    final backgroundAsset = state.mode.isFriends
        ? 'assets/background-setup-friends-mode.png'
        : 'assets/background-setup-couple-mode.png';
    final badgeColor = state.mode.isFriends ? const Color.fromARGB(255, 7, 135, 255) : const Color(0xFFE94494);
    final startGradient = state.mode.isFriends
        ? const [Color(0xFF59B8FF), Color(0xFF266FB9)]
        : const [Color(0xFFFF71B7), Color(0xFFD93D88)];

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(backgroundAsset, fit: BoxFit.cover),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: SizedBox(
                    height: 112,
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(child: Image.asset('assets/logo-+18.png', width: 160, fit: BoxFit.contain)),
                        ),
                        const Spacer(),
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
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      160 + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Numero',
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontSize: 50 * 0.66,
                                    fontWeight: FontWeight.w700,
                                    color: modeAccent,
                                  ),
                                ),
                                TextSpan(
                                  text: ' de ${state.countTitle}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displaySmall?.copyWith(fontSize: 50 * 0.66, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SetupCountSelector(
                          count: state.groupCount,
                          canIncrement: _controller.canIncrement,
                          canDecrement: _controller.canDecrement,
                          onIncrement: _controller.incrementCount,
                          onDecrement: _controller.decrementCount,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Nombre de cada jugador',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(fontSize: 34 * 0.45, fontWeight: FontWeight.w700),
                        ),
                        if (state.participantRangeLabel.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            state.participantRangeLabel,
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        if (state.mode.isFriends)
                          _FriendsPlayersList(
                            players: state.players,
                            badgeColor: badgeColor,
                            accentTint: modeAccent,
                            nameControllers: _nameControllers,
                            hasError: _controller.playerHasError,
                            onNameChanged: (playerId, value) =>
                                _controller.updatePlayerName(playerId: playerId, value: value),
                          )
                        else
                          _CouplesPlayersList(
                            pairCount: state.groupCount,
                            players: state.players,
                            badgeColor: badgeColor,
                            accentTint: modeAccent,
                            nameControllers: _nameControllers,
                            hasError: _controller.playerHasError,
                            onNameChanged: (playerId, value) =>
                                _controller.updatePlayerName(playerId: playerId, value: value),
                          ),
                        const SizedBox(height: AppSpacing.xl),
                        for (final theme in GameStyleTheme.values) ...[
                          GameStyleCard(
                            label: theme.label,
                            iconAsset: theme.iconAsset,
                            accentColor: theme.accentColor,
                            isSelected: state.selectedTheme == theme,
                            isLocked: state.themeIsLocked(theme),
                            useCleanInframundoIcon: theme == GameStyleTheme.inframundo,
                            onTap: () => _controller.selectTheme(theme),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        if (!state.isPremium) ...[const _PremiumUpsellBanner(), const SizedBox(height: AppSpacing.xl)],
                        PlayerSetupPrimaryButton(
                          label: 'Comenzar',
                          gradientColors: startGradient,
                          enabled: state.canStart,
                          onTap: _onSubmit,
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
      bottomNavigationBar: GlobalBottomMenu(
        currentItem: _bottomMenuItem,
        onItemSelected: (item) {
          setState(() {
            _bottomMenuItem = item;
          });
          if (item == GlobalBottomMenuItem.home && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}

class _FriendsPlayersList extends StatelessWidget {
  const _FriendsPlayersList({
    required this.players,
    required this.badgeColor,
    required this.accentTint,
    required this.nameControllers,
    required this.hasError,
    required this.onNameChanged,
  });

  final List<PlayerConfig> players;
  final Color badgeColor;
  final Color accentTint;
  final Map<int, TextEditingController> nameControllers;
  final bool Function(int playerId) hasError;
  final void Function(int playerId, String value) onNameChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final player in players) ...[
          PlayerNameCard(
            index: player.id,
            controller: nameControllers[player.id]!,
            badgeColor: badgeColor,
            accentTint: accentTint,
            showError: hasError(player.id),
            onChanged: (value) => onNameChanged(player.id, value),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _CouplesPlayersList extends StatelessWidget {
  const _CouplesPlayersList({
    required this.pairCount,
    required this.players,
    required this.badgeColor,
    required this.accentTint,
    required this.nameControllers,
    required this.hasError,
    required this.onNameChanged,
  });

  final int pairCount;
  final List<PlayerConfig> players;
  final Color badgeColor;
  final Color accentTint;
  final Map<int, TextEditingController> nameControllers;
  final bool Function(int playerId) hasError;
  final void Function(int playerId, String value) onNameChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var pairIndex = 0; pairIndex < pairCount; pairIndex++) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 14, 14, 14).withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Pareja ${pairIndex + 1}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Nombre de cada jugador',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final player in players.where((candidate) => candidate.pairIndex == pairIndex)) ...[
            PlayerNameCard(
              index: player.id,
              controller: nameControllers[player.id]!,
              badgeColor: badgeColor,
              accentTint: accentTint,
              showError: hasError(player.id),
              onChanged: (value) => onNameChanged(player.id, value),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (pairIndex != pairCount - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _PremiumUpsellBanner extends StatelessWidget {
  const _PremiumUpsellBanner();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/logo-icon-premium-container.png', width: 54, height: 54, fit: BoxFit.contain),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Hasta '),
                TextSpan(
                  text: 'Premium',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' y desbloquea los\ndemás estilos de juego'),
              ],
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.2,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        // const SizedBox(width: AppSpacing.sm),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE55D), Color(0xFFF0A91B)],
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/premium-icon-logo.png',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
                color: const Color(0xFF865E00),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                'Premium',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: const Color(0xFF865E00), fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderSideButton extends StatelessWidget {
  const _HeaderSideButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 104,
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
              border: Border.all(color: const Color(0xFF1176E3).withValues(alpha: 0.48), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F66C9).withValues(alpha: 0.24),
                  blurRadius: 10,
                  spreadRadius: -2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(Icons.chevron_left_rounded, size: 38, color: const Color(0xFF20A5FF).withValues(alpha: 0.95)),
            ),
          ),
        ),
      ),
    );
  }
}
