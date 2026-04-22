import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/global_bottom_menu.dart';
import '../../../match_play/domain/entities/game_prompt.dart';
import '../../../match_play/presentation/providers/match_providers.dart';
import '../../../match_play/domain/entities/truth_or_dare_option.dart';
import '../../../match_play/presentation/pages/truth_or_dare_turn_page.dart';
import '../../../player_setup/presentation/pages/truth_or_dare_selection_page.dart';
import '../../../player_setup/presentation/widgets/premium_glass_surface.dart';
import '../../../premium/presentation/pages/premium_menu_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../domain/entities/game_mode.dart';
import '../widgets/home_mode_carousel.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    this.skipActiveMatchDialog = false,
    this.showBottomMenu = true,
    this.onGlobalMenuRequested,
    super.key,
  });

  final bool skipActiveMatchDialog;
  final bool showBottomMenu;
  final ValueChanged<GlobalBottomMenuItem>? onGlobalMenuRequested;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  var _resumePromptShown = false;
  var _selectedMode = GameMode.couples;

  @override
  void initState() {
    super.initState();
    if (widget.skipActiveMatchDialog) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeResumeMatch();
    });
  }

  Future<void> _maybeResumeMatch() async {
    if (_resumePromptShown || !mounted) {
      return;
    }

    final matchController = ref.read(matchControllerProvider);
    final session = matchController.session;
    if (session == null || session.isFinished) {
      return;
    }
    final hasAnyPoints = matchController.scoresByPlayerId.values.any(
      (score) => score != 0,
    );
    if (!hasAnyPoints) {
      return;
    }

    _resumePromptShown = true;
    final decision = await showDialog<_ResumeDecision>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Partida activa detectada'),
          content: const Text(
            'Hay una partida local en curso. Quieres reanudarla o descartarla?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(_ResumeDecision.discard),
              child: const Text('Descartar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_ResumeDecision.resume),
              child: const Text('Reanudar'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (decision == _ResumeDecision.discard) {
      await matchController.discardActiveMatch();
      ref.read(activeSetupSubmissionProvider.notifier).state = null;
      return;
    }

    if (decision != _ResumeDecision.resume) {
      return;
    }

    final submission = matchController.activeSetupSubmission;
    if (submission == null) {
      return;
    }
    ref.read(activeSetupSubmissionProvider.notifier).state = submission;

    final pendingTurn = matchController.currentTurn;
    if (pendingTurn != null) {
      final option = pendingTurn.promptKind == MatchPromptKind.question
          ? TruthOrDareOption.verdad
          : TruthOrDareOption.reto;
      final currentPoints =
          matchController.scoresByPlayerId[pendingTurn.participantId] ?? 0;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TruthOrDareTurnPage(
            submission: submission,
            option: option,
            round: pendingTurn.roundNumber,
            points: currentPoints,
            initialTurn: pendingTurn,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TruthOrDareSelectionPage(submission: submission),
      ),
    );
  }

  void _openPremium() {
    if (widget.onGlobalMenuRequested != null) {
      widget.onGlobalMenuRequested!(GlobalBottomMenuItem.ranking);
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const PremiumMenuPage()));
  }

  void _openTutorial() {
    Navigator.of(context).pushReplacementNamed('/tutorial');
  }

  void _onItemSelected(GlobalBottomMenuItem item) {
    if (widget.onGlobalMenuRequested != null) {
      widget.onGlobalMenuRequested!(item);
      return;
    }

    if (item == GlobalBottomMenuItem.home) {
      return;
    }

    if (item == GlobalBottomMenuItem.ranking) {
      _openPremium();
      return;
    }
    if (item == GlobalBottomMenuItem.profile) {
      AppRouter.openProfileGuarded(context);
      return;
    }
    if (item == GlobalBottomMenuItem.settings) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
      return;
    }
  }

  void _onModeChanged(GameMode mode) {
    if (_selectedMode == mode) {
      return;
    }
    setState(() {
      _selectedMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background-mode.png', fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x4D04010B), AppColors.backgroundOverlayBottom],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final carouselHeight = (constraints.maxHeight * 0.62).clamp(
                  360.0,
                  480.0,
                );
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _HomeTopActionPill(
                            label: 'Premium',
                            textColor: const Color(0xFFF6A117),
                            borderColor: const Color(0xCCBB7605),
                            icon: Image.asset(
                              'assets/premium-icon-logo.png',
                              width: 18,
                              height: 18,
                              fit: BoxFit.contain,
                              color: const Color(0xFFF6A117),
                            ),
                            onTap: _openPremium,
                          ),
                          _HomeTopActionPill(
                            label: 'Tutorial',
                            textColor: Colors.white.withValues(alpha: 0.92),
                            borderColor: Colors.white.withValues(alpha: 0.52),
                            icon: Image.asset(
                              'assets/logo-icon-question.png',
                              width: 16,
                              height: 16,
                              fit: BoxFit.contain,
                            ),
                            usePremiumSurface: true,
                            onTap: _openTutorial,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Image.asset(
                      _selectedMode.isCouples
                          ? 'assets/logo-simple-signature.png'
                          : 'assets/logo-simple-blue.png',
                      height: _selectedMode.isCouples ? 88 : 88,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: _HomeModeHeroCopy(mode: _selectedMode),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                      height: carouselHeight,
                      child: HomeModeCarousel(onModeChanged: _onModeChanged),
                    ),
                    const SizedBox(height: AppSpacing.xxl * 1.5),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: _HomeModeInfoBanner(),
                    ),
                    const SizedBox(height: AppSpacing.xxl * 4.5),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomMenu
          ? GlobalBottomMenu(
              currentItem: GlobalBottomMenuItem.home,
              onItemSelected: _onItemSelected,
            )
          : null,
    );
  }
}

enum _ResumeDecision { resume, discard }

class _HomeTopActionPill extends StatelessWidget {
  const _HomeTopActionPill({
    required this.label,
    required this.textColor,
    required this.borderColor,
    required this.icon,
    required this.onTap,
    this.usePremiumSurface = false,
  });

  final String label;
  final Color textColor;
  final Color borderColor;
  final Widget icon;
  final VoidCallback onTap;
  final bool usePremiumSurface;

  @override
  Widget build(BuildContext context) {
    final buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: usePremiumSurface
            ? IntrinsicWidth(
                child: SizedBox(
                  height: 46,
                  child: PremiumGlassSurface(
                    borderRadius: BorderRadius.circular(16),
                    borderColor: borderColor,
                    gradientColors: [
                      const Color(0xFF1E1737).withValues(alpha: 0.86),
                      const Color(0xFF0F0C22).withValues(alpha: 0.72),
                    ],
                    topHighlightOpacity: 0.12,
                    bottomShadeOpacity: 0.12,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Center(child: buttonChild),
                  ),
                ),
              )
            : Ink(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1E1737).withValues(alpha: 0.86),
                      const Color(0xFF0F0C22).withValues(alpha: 0.72),
                    ],
                  ),
                ),
                child: SizedBox(height: 46, child: Center(child: buttonChild)),
              ),
      ),
    );
  }
}

class _HomeModeInfoBanner extends StatelessWidget {
  const _HomeModeInfoBanner();

  @override
  Widget build(BuildContext context) {
    return PremiumGlassSurface(
      height: 102,
      borderRadius: BorderRadius.circular(24),
      gradientColors: const [Color(0x73302043), Color(0x7A1A0E2A)],
      borderColor: Colors.white.withValues(alpha: 0.38),
      innerBorderColor: Colors.white.withValues(alpha: 0.12),
      topHighlightOpacity: 0.12,
      bottomShadeOpacity: 0.24,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/logo-icon-foco-premium.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'La dinámica cambia según el modo de juego que selecciones.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 17,
                color: Colors.white.withValues(alpha: 0.96),
                height: 1.35,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeModeHeroCopy extends StatelessWidget {
  const _HomeModeHeroCopy({required this.mode});

  final GameMode mode;

  @override
  Widget build(BuildContext context) {
    final accentColor = mode.isCouples
        ? AppColors.primary
        : AppColors.secondary;
    final subtitle = mode.isCouples
        ? 'No es lo mismo jugar en pareja... que\ncon todo el grupo mirando.'
        : 'No es lo mismo jugar con amigos... que\ncon tu pareja mirando.';
    return Column(
      children: [
        Text.rich(
          TextSpan(
            text: 'Elige cómo ',
            children: [
              TextSpan(
                text: 'quieres jugar',
                style: TextStyle(color: accentColor),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            height: 1.12,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.92),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
