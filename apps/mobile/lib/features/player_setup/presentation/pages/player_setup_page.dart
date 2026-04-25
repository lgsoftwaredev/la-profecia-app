import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_3d_pill_button.dart';
import '../../../../core/widgets/global_bottom_menu.dart';
import '../../../../core/widgets/premium_slide_button.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../game_mode_selection/presentation/pages/main_menu_shell_page.dart';
import '../../../match_play/presentation/controllers/match_controller.dart';
import '../../../match_play/presentation/providers/match_providers.dart';
import '../../../premium/presentation/providers/premium_providers.dart';
import '../../../profile/domain/entities/editable_profile.dart';
import '../../../profile/presentation/widgets/editable_profile_dialog.dart';
import '../../domain/entities/game_setup_models.dart';
import '../providers/player_setup_providers.dart';
import 'player_selection_intro_page.dart';
import '../widgets/game_style_card.dart';
import '../widgets/premium_glass_surface.dart';
import '../widgets/setup_count_selector.dart';

class PlayerSetupPage extends ConsumerStatefulWidget {
  const PlayerSetupPage({
    required this.mode,
    this.isPremium = false,
    this.onStart,
    super.key,
  });

  final GameMode mode;
  final bool isPremium;
  final ValueChanged<GameSetupSubmission>? onStart;

  @override
  ConsumerState<PlayerSetupPage> createState() => _PlayerSetupPageState();
}

class _PlayerSetupPageState extends ConsumerState<PlayerSetupPage> {
  late final PlayerSetupParams _params;
  ProviderSubscription<bool>? _premiumSubscription;
  var _showPremiumText = false;

  @override
  void initState() {
    super.initState();
    final initialPremium = widget.isPremium || ref.read(premiumAccessProvider);
    _params = PlayerSetupParams(mode: widget.mode, isPremium: initialPremium);
    _premiumSubscription = ref.listenManual<bool>(premiumAccessProvider, (
      previous,
      next,
    ) {
      final effectivePremium = widget.isPremium || next;
      ref
          .read(playerSetupControllerProvider(_params))
          .setPremiumAccess(effectivePremium);
    }, fireImmediately: true);
    Future<void>(() async {
      await ref.read(premiumAccessProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _premiumSubscription?.close();
    super.dispose();
  }

  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainMenuShellPage()),
      (route) => false,
    );
  }

  Future<void> _openTutorial() async {
    await Navigator.of(context).pushNamed('/tutorial');
  }

  Future<void> _openPlayerEditor(PlayerConfig player) async {
    final hideIdentityAndAttraction = _params.mode.isCouples;
    final updated = await showDialog<EditableProfile>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (dialogContext) {
        final size = MediaQuery.sizeOf(dialogContext);
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 620,
              maxHeight: size.height * (_params.mode.isCouples ? 0.48 : 0.62),
            ),
            child: Dialog(
              alignment: Alignment.center,
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.lg,
              ),
              child: EditableProfileDialog(
                initialProfile: EditableProfile(
                  displayName: player.name,
                  identity: player.identity,
                  attraction: player.attraction,
                ),
                avatarAssetPath: player.avatarAssetPath,
                showIdentitySection: !hideIdentityAndAttraction,
                showAttractionSection: !hideIdentityAndAttraction,
                onSave:
                    ({
                      required String displayName,
                      required ProfileIdentity identity,
                      required ProfileAttraction attraction,
                    }) async {
                      return EditableProfile(
                        displayName: displayName.trim(),
                        identity: identity,
                        attraction: attraction,
                      );
                    },
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || updated == null) {
      return;
    }

    if (_params.mode.isCouples) {
      ref
          .read(playerSetupControllerProvider(_params))
          .updatePlayerName(playerId: player.id, value: updated.displayName);
      return;
    }

    ref
        .read(playerSetupControllerProvider(_params))
        .applyPlayerProfile(
          playerId: player.id,
          displayName: updated.displayName,
          identity: updated.identity!,
          attraction: updated.attraction!,
        );
  }

  Future<bool> _confirmLeaveForPremium() async {
    final decision = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ir a Premium'),
          content: const Text(
            'La partida actual tiene progreso. Si continúas se descartará y se abrirá Premium.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
    return decision ?? false;
  }

  Future<void> _openPremium({
    required bool hasStartedMatch,
    required MatchController matchController,
  }) async {
    if (hasStartedMatch) {
      final shouldContinue = await _confirmLeaveForPremium();
      if (!mounted || !shouldContinue) {
        return;
      }
      await matchController.discardActiveMatch();
      ref.read(activeSetupSubmissionProvider.notifier).state = null;
    }

    if (!mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) =>
            const MainMenuShellPage(initialItem: GlobalBottomMenuItem.ranking),
      ),
      (route) => false,
    );
  }

  Future<void> _onPremiumSlideTap({
    required bool hasStartedMatch,
    required MatchController matchController,
  }) async {
    if (!_showPremiumText) {
      setState(() {
        _showPremiumText = true;
      });
      return;
    }

    await _openPremium(
      hasStartedMatch: hasStartedMatch,
      matchController: matchController,
    );
  }

  void _onSubmit() {
    final controller = ref.read(playerSetupControllerProvider(_params));
    final submission = controller.submit();
    if (submission == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa el nombre de todos los jugadores.'),
        ),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    ref.read(activeSetupSubmissionProvider.notifier).state = submission;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlayerSelectionIntroPage(submission: submission),
      ),
    );
    widget.onStart?.call(submission);
  }

  @override
  Widget build(BuildContext context) {
    final setupController = ref.watch(playerSetupControllerProvider(_params));
    final state = setupController.state;
    final isPremium = widget.isPremium || ref.watch(premiumAccessProvider);
    final matchController = ref.watch(matchControllerProvider);
    final scoresByPlayerId = ref.watch(matchScoresProvider);
    final hasActiveMatch = ref.watch(hasActiveMatchProvider);
    final activeSubmission = ref.watch(activeSetupSubmissionProvider);

    final hasAnyPoints = scoresByPlayerId.values.any((score) => score != 0);
    final hasStartedMatch =
        hasActiveMatch || activeSubmission != null || hasAnyPoints;

    final modeAccent = state.mode.isFriends
        ? const Color.fromARGB(255, 7, 135, 255)
        : const Color(0xFFE94494);
    final backgroundAsset = state.mode.isFriends
        ? 'assets/background-setup-friends-mode.png'
        : 'assets/background-setup-couple-mode.png';
    final startGradient = state.mode.isFriends
        ? const [Color(0xFF2BC0FF), Color(0xFF127AC9)]
        : const [Color(0xFFF23A98), Color(0xFFB50063)];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _goToHome();
      },
      child: Scaffold(
        extendBody: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(backgroundAsset, fit: BoxFit.cover),
            SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _HeaderActionPill(
                              label: 'Inicio',
                              icon: const Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.white,
                                size: 23,
                              ),
                              onTap: _goToHome,
                            ),
                            _HeaderActionPill(
                              label: 'Tutorial',
                              icon: Image.asset(
                                'assets/logo-icon-question.png',
                                width: 16,
                                height: 16,
                                fit: BoxFit.contain,
                              ),
                              onTap: _openTutorial,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Image.asset(
                        state.mode.isFriends
                            ? 'assets/logo-simple-blue.png'
                            : 'assets/logo-simple-signature.png',
                        height: 78,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            170,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Número',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                              fontSize: 50 * 0.66,
                                              fontWeight: FontWeight.w700,
                                              color: modeAccent,
                                            ),
                                      ),
                                      TextSpan(
                                        text: ' de ${state.countTitle}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                              fontSize: 50 * 0.66,
                                              fontWeight: FontWeight.w400,
                                            ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              SetupCountSelector(
                                count: state.groupCount,
                                canIncrement: setupController.canIncrement,
                                canDecrement: setupController.canDecrement,
                                onIncrement: setupController.incrementCount,
                                onDecrement: setupController.decrementCount,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                state.participantRangeLabel,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.90,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              if (!(state.mode.isCouples && isPremium)) ...[
                                _InfoBanner(
                                  mode: state.mode,
                                  isPremium: isPremium,
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],
                              if (state.mode.isCouples && state.groupCount <= 1)
                                Text(
                                  'Nombre de cada jugador',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                )
                              else if (!state.mode.isCouples)
                                Text(
                                  'Nombra a cada jugador',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                ),
                              const SizedBox(height: AppSpacing.sm),
                              if (state.mode.isFriends)
                                _FriendsPlayersList(
                                  players: state.players,
                                  isPremium: isPremium,
                                  onTap: _openPlayerEditor,
                                )
                              else
                                _CouplesPlayersList(
                                  players: state.players,
                                  onTap: _openPlayerEditor,
                                ),
                              const SizedBox(height: AppSpacing.lg),
                              Image.asset(
                                'assets/divider-premium.png',
                                fit: BoxFit.contain,
                              ),
                              Center(
                                child: Text(
                                  'Modos de juego',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Center(
                                child: Text(
                                  'Selecciona los niveles a jugar',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.84,
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              if (isPremium) ...[
                                for (final theme in GameStyleTheme.values) ...[
                                  GameStyleCard(
                                    label: theme.label,
                                    subtitle: theme.subtitle,
                                    iconAsset: theme.iconAsset,
                                    accentColor: theme.accentColor,
                                    isSelected: state.isThemeEnabled(theme),
                                    isLocked: state.themeIsLocked(theme),
                                    onTap: () =>
                                        setupController.toggleTheme(theme),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                ],
                              ] else ...[
                                _NonPremiumGameModesSection(
                                  cieloSelected: state.isThemeEnabled(
                                    GameStyleTheme.cielo,
                                  ),
                                  onTapCielo: () => setupController.toggleTheme(
                                    GameStyleTheme.cielo,
                                  ),
                                  onTapPremium: () => _openPremium(
                                    hasStartedMatch: hasStartedMatch,
                                    matchController: matchController,
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.lg),
                              Opacity(
                                opacity: state.canStart ? 1 : 0.65,
                                child: App3dPillButton(
                                  label: 'Comenzar partida',
                                  color: startGradient.first,
                                  gradientColors: startGradient,
                                  height: 76,
                                  depth: 4.8,
                                  borderRadius: 20,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontSize: 41 * 0.46,
                                        fontWeight: FontWeight.w700,
                                      ),
                                  onTap: _onSubmit,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!isPremium)
                    Positioned(
                      top: 150,
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
                          onTap: () => _onPremiumSlideTap(
                            hasStartedMatch: hasStartedMatch,
                            matchController: matchController,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionPill extends StatelessWidget {
  const _HeaderActionPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1E1737).withValues(alpha: 0.86),
                const Color(0xFF0F0C22).withValues(alpha: 0.72),
              ],
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: AppSpacing.xxs),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.96),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.mode, required this.isPremium});

  final GameMode mode;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final iconAsset = isPremium
        ? 'assets/logo-icon-foco-premium.png'
        : 'assets/logo-icon-premium-container.png';
    final text = mode.isFriends
        ? isPremium
              ? 'Completa nombre, identidad y gustos si quieres activar preguntas hot según tus preferencias'
              : 'Con Premium podrás ajustar tus gustos para recibir preguntas y retos personalizados'
        : 'Con Premium podrás tener preguntas y retos personalizadas para cada pareja.';
    return PremiumGlassSurface(
      height: 66,
      borderRadius: BorderRadius.circular(22),
      gradientColors: [
        const Color(0xFF14223C).withValues(alpha: 0.62),
        const Color(0xFF0A162A).withValues(alpha: 0.50),
      ],
      borderColor: Colors.white.withValues(alpha: 0.30),
      innerBorderColor: Colors.white.withValues(alpha: 0.08),
      topHighlightOpacity: 0.10,
      bottomShadeOpacity: 0.20,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      child: Row(
        children: [
          Image.asset(iconAsset, width: 34, height: 34, fit: BoxFit.contain),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.90),
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendsPlayersList extends StatelessWidget {
  const _FriendsPlayersList({
    required this.players,
    required this.isPremium,
    required this.onTap,
  });

  final List<PlayerConfig> players;
  final bool isPremium;
  final ValueChanged<PlayerConfig> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final player in players) ...[
          _FriendsPlayerCard(
            player: player,
            isPremium: isPremium,
            onTap: () => onTap(player),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _FriendsPlayerCard extends StatelessWidget {
  const _FriendsPlayerCard({
    required this.player,
    required this.isPremium,
    required this.onTap,
  });

  final PlayerConfig player;
  final bool isPremium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isComplete =
        player.identity != null &&
        player.attraction != null &&
        player.name.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: PremiumGlassSurface(
          height: 86,
          borderRadius: BorderRadius.circular(24),
          gradientColors: [
            const Color(0xFF2A355A).withValues(alpha: 0.70),
            const Color(0xFF171D34).withValues(alpha: 0.62),
          ],
          borderColor: Colors.white.withValues(alpha: 0.30),
          innerBorderColor: Colors.white.withValues(alpha: 0.10),
          topHighlightOpacity: 0.10,
          bottomShadeOpacity: 0.20,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              _Avatar(assetPath: player.avatarAssetPath),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name.trim().isEmpty
                          ? 'Jugador ${player.id}'
                          : player.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 32 * 0.58,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _PreferenceChip(
                          label:
                              player.identity?.label ??
                              (isPremium
                                  ? 'Sin identificación'
                                  : 'No disponible'),
                          assetPath: player.identity?.iconAssetPath,
                          active: player.identity != null,
                          activeColor: player.identity == ProfileIdentity.woman
                              ? const Color(0xFFE94494)
                              : const Color(0xFF1FA7FF),
                        ),
                        const SizedBox(width: 6),
                        _PreferenceChip(
                          label:
                              player.attraction?.label ??
                              (isPremium
                                  ? 'Sin preferencias'
                                  : 'No disponible'),
                          assetPath: 'assets/logo-icon-hearth-filled.png',
                          active: player.attraction != null,
                          activeColor: const Color(0xFFE94494),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                color: isComplete
                    ? const Color(0xFF12D46A)
                    : const Color(0xFF9E3B51),
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CouplesPlayersList extends StatelessWidget {
  const _CouplesPlayersList({required this.players, required this.onTap});

  final List<PlayerConfig> players;
  final ValueChanged<PlayerConfig> onTap;

  @override
  Widget build(BuildContext context) {
    final playersByPair = <int, List<PlayerConfig>>{};
    for (final player in players) {
      final pairIndex = player.pairIndex ?? ((player.id - 1) ~/ 2);
      playersByPair.putIfAbsent(pairIndex, () => <PlayerConfig>[]).add(player);
    }
    final orderedPairIndexes = playersByPair.keys.toList(growable: false)
      ..sort();
    final hasMultiplePairs = orderedPairIndexes.length > 1;

    return Column(
      children: [
        for (var i = 0; i < orderedPairIndexes.length; i++) ...[
          if (hasMultiplePairs) ...[
            _CoupleSectionHeader(pairNumber: orderedPairIndexes[i] + 1),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.xs),
          for (final player in playersByPair[orderedPairIndexes[i]]!) ...[
            _CouplePlayerCard(player: player, onTap: () => onTap(player)),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (i != orderedPairIndexes.length - 1)
            const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _CoupleSectionHeader extends StatelessWidget {
  const _CoupleSectionHeader({required this.pairNumber});

  final int pairNumber;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CouplesCountPill(pairCount: pairNumber),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Nombre de cada jugador',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _CouplesCountPill extends StatelessWidget {
  const _CouplesCountPill({required this.pairCount});

  final int pairCount;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: const Color(0xFF171623).withValues(alpha: 0.88),
        ),
        child: Text(
          'Pareja $pairCount',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.98),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class _CouplePlayerCard extends StatelessWidget {
  const _CouplePlayerCard({required this.player, required this.onTap});

  final PlayerConfig player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: PremiumGlassSurface(
          height: 86,
          borderRadius: BorderRadius.circular(24),
          gradientColors: [
            const Color(0xFF3D2A48).withValues(alpha: 0.68),
            const Color(0xFF291E31).withValues(alpha: 0.58),
          ],
          borderColor: Colors.white.withValues(alpha: 0.30),
          innerBorderColor: Colors.white.withValues(alpha: 0.10),
          topHighlightOpacity: 0.10,
          bottomShadeOpacity: 0.20,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: [
              _Avatar(assetPath: player.avatarAssetPath),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  player.name.trim().isEmpty
                      ? 'Jugador ${player.id}'
                      : player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 32 * 0.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: 0.28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Image.asset(assetPath, fit: BoxFit.contain),
      ),
    );
  }
}

class _PreferenceChip extends StatelessWidget {
  const _PreferenceChip({
    required this.label,
    required this.active,
    required this.activeColor,
    this.assetPath,
  });

  final String label;
  final bool active;
  final Color activeColor;
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : const Color(0xFF98A0AE);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: active ? 0.58 : 0.42),
        ),
        color: color.withValues(alpha: active ? 0.16 : 0.06),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (assetPath != null)
            Image.asset(
              assetPath!,
              width: 14,
              height: 14,
              fit: BoxFit.contain,
              color: color,
            )
          else
            Image.asset(
              ProfileAttraction.men.iconAssetPath,
              width: 12,
              height: 12,
              fit: BoxFit.contain,
              color: color,
            ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color.withValues(alpha: active ? 0.98 : 0.90),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.complete, required this.isPremium});

  final bool complete;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final color = !isPremium
        ? const Color(0xFF98A0AE)
        : complete
        ? const Color(0xFF0CC55A)
        : const Color(0xFF9E3B51);
    final text = !isPremium
        ? 'No disponible'
        : complete
        ? 'Completo'
        : 'Pendiente';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.22),
        border: Border.all(color: color.withValues(alpha: 0.62)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NonPremiumGameModesSection extends StatelessWidget {
  const _NonPremiumGameModesSection({
    required this.cieloSelected,
    required this.onTapCielo,
    required this.onTapPremium,
  });

  final bool cieloSelected;
  final VoidCallback onTapCielo;
  final VoidCallback onTapPremium;

  String _labelForLockedTheme(GameStyleTheme theme) {
    return switch (theme) {
      GameStyleTheme.cielo => 'Cielo',
      GameStyleTheme.tierra => 'Tierra',
      GameStyleTheme.infierno => 'Infierno',
      GameStyleTheme.inframundo => 'Inframundo',
    };
  }

  @override
  Widget build(BuildContext context) {
    final themesByType = {
      for (final theme in GameStyleTheme.values) theme: theme,
    };
    final cielo = themesByType[GameStyleTheme.cielo]!;
    final tierra = themesByType[GameStyleTheme.tierra]!;
    final infierno = themesByType[GameStyleTheme.infierno]!;
    final inframundo = themesByType[GameStyleTheme.inframundo]!;

    return Column(
      children: [
        GameStyleCard(
          label: cielo.label,
          subtitle: cielo.subtitle,
          iconAsset: cielo.iconAsset,
          accentColor: cielo.accentColor,
          isSelected: cieloSelected,
          isLocked: false,
          onTap: onTapCielo,
        ),
        const SizedBox(height: AppSpacing.lg),
        _PremiumUpsellBanner(onTap: onTapPremium),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: GameStyleCard(
                label: _labelForLockedTheme(tierra),
                subtitle: tierra.subtitle,
                iconAsset: tierra.iconAsset,
                accentColor: tierra.accentColor,
                isSelected: false,
                isLocked: true,
                layout: GameStyleCardLayout.lockedCompact,
                showPremiumCornerBadge: true,
                onTap: onTapPremium,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GameStyleCard(
                label: _labelForLockedTheme(infierno),
                subtitle: infierno.subtitle,
                iconAsset: infierno.iconAsset,
                accentColor: infierno.accentColor,
                isSelected: false,
                isLocked: true,
                layout: GameStyleCardLayout.lockedCompact,
                showPremiumCornerBadge: true,
                onTap: onTapPremium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GameStyleCard(
          label: _labelForLockedTheme(inframundo),
          subtitle: inframundo.subtitle,
          iconAsset: inframundo.iconAsset,
          accentColor: inframundo.accentColor,
          isSelected: false,
          isLocked: true,
          layout: GameStyleCardLayout.lockedCompact,
          showPremiumCornerBadge: true,
          onTap: onTapPremium,
        ),
      ],
    );
  }
}

class _PremiumUpsellBanner extends StatelessWidget {
  const _PremiumUpsellBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            'assets/logo-icon-premium-container.png',
            fit: BoxFit.contain,
          ),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Compra '),
                TextSpan(
                  text: 'Premium',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(
                  text: ' y desbloquea\nlos demás estilos de juego',
                ),
              ],
            ),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.2,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Ink(
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF865E00),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
