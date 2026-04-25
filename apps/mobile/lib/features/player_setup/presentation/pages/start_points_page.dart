import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/premium_slide_button.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../game_mode_selection/presentation/pages/home_page.dart';
import '../../../match_play/domain/entities/match_level.dart';
import '../../../match_play/presentation/pages/final_judgment_page.dart';
import '../../../match_play/presentation/providers/match_providers.dart';
import '../../../match_play/presentation/utils/active_player_name_resolver.dart';
import '../../../premium/presentation/pages/premium_menu_page.dart';
import '../../../premium/presentation/providers/premium_providers.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../domain/entities/game_setup_models.dart';
import '../widgets/level_card_frame.dart';
import '../widgets/premium_glass_surface.dart';
import '../widgets/start_points_roulette_wheel.dart';
import 'truth_or_dare_selection_page.dart';

class StartPointsPage extends ConsumerStatefulWidget {
  const StartPointsPage({required this.submission, super.key});

  final GameSetupSubmission submission;

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

  late List<GameStyleTheme> _enabledThemes = _normalizeThemes(
    widget.submission.enabledThemes,
  );
  late List<GameStyleTheme> _draftEnabledThemes = [..._enabledThemes];
  late GameStyleTheme _selectedTheme = _initialSelectedTheme(
    _enabledThemes,
    widget.submission.preferredTheme,
  );
  var _didBootstrapMatch = false;
  var _isEditingEnabledThemes = false;
  var _isHandlingBackAction = false;
  var _showPremiumText = false;

  static List<GameStyleTheme> _normalizeThemes(List<GameStyleTheme> input) {
    final normalized = _order.where(input.contains).toList(growable: false);
    if (normalized.isEmpty) {
      return const <GameStyleTheme>[GameStyleTheme.cielo];
    }
    return normalized;
  }

  static GameStyleTheme _initialSelectedTheme(
    List<GameStyleTheme> enabledThemes,
    GameStyleTheme preferredTheme,
  ) {
    if (enabledThemes.contains(preferredTheme)) {
      return preferredTheme;
    }
    return enabledThemes.first;
  }

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

  GameSetupSubmission _submissionWithThemes({
    required GameSetupSubmission base,
    required List<GameStyleTheme> enabledThemes,
  }) {
    return GameSetupSubmission(
      mode: base.mode,
      players: base.players,
      pairs: base.pairs,
      enabledThemes: enabledThemes,
    );
  }

  Future<void> _bootstrapMatch() async {
    final controller = ref.read(matchControllerProvider);
    final submission = _submissionWithThemes(
      base: widget.submission,
      enabledThemes: _enabledThemes,
    );
    if (!controller.hasActiveMatch) {
      await controller.createMatch(submission);
    }
    ref.read(activeSetupSubmissionProvider.notifier).state = submission;
  }

  String get _backgroundAsset => widget.submission.mode.isFriends
      ? 'assets/background-setup-friends-mode.png'
      : 'assets/background-setup-couple-mode.png';

  Future<void> _openTruthOrDareSelectionPage(
    GameStyleTheme selectedTheme,
  ) async {
    final base = ref.read(activeSetupSubmissionProvider) ?? widget.submission;
    final submission = _submissionWithThemes(
      base: base,
      enabledThemes: _enabledThemes,
    );
    ref.read(activeSetupSubmissionProvider.notifier).state = submission;
    if (!mounted) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TruthOrDareSelectionPage(
          submission: submission,
          selectedTheme: selectedTheme,
        ),
      ),
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
  }

  Future<void> _openPremium() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const PremiumMenuPage()));
  }

  Future<void> _onPremiumSlideTap() async {
    if (!_showPremiumText) {
      setState(() {
        _showPremiumText = true;
      });
      return;
    }
    await _openPremium();
  }

  void _startEditingThemes() {
    setState(() {
      _draftEnabledThemes = [..._enabledThemes];
      _isEditingEnabledThemes = true;
    });
  }

  void _cancelEditingThemes() {
    setState(() {
      _draftEnabledThemes = [..._enabledThemes];
      _isEditingEnabledThemes = false;
    });
  }

  void _toggleDraftTheme({
    required GameStyleTheme theme,
    required bool isPremium,
  }) {
    if (!_isEditingEnabledThemes) {
      return;
    }
    if (!isPremium) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const PremiumMenuPage()));
      return;
    }

    final selected = _draftEnabledThemes.contains(theme);
    if (selected && _draftEnabledThemes.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes mantener al menos un nivel habilitado.'),
        ),
      );
      return;
    }

    setState(() {
      if (selected) {
        _draftEnabledThemes = _draftEnabledThemes
            .where((item) => item != theme)
            .toList(growable: false);
      } else {
        _draftEnabledThemes = [..._draftEnabledThemes, theme];
      }
      _draftEnabledThemes = _normalizeThemes(_draftEnabledThemes);
    });
  }

  Future<void> _confirmEnabledThemes() async {
    final normalizedThemes = _normalizeThemes(_draftEnabledThemes);
    final base = ref.read(activeSetupSubmissionProvider) ?? widget.submission;
    final submission = _submissionWithThemes(
      base: base,
      enabledThemes: normalizedThemes,
    );
    final controller = ref.read(matchControllerProvider);
    if (!controller.hasActiveMatch) {
      await controller.createMatch(submission);
    }
    final updated = await controller.updateAllowedLevels(
      normalizedThemes
          .map((theme) => theme.toMatchLevel)
          .toList(growable: false),
    );
    if (!mounted) {
      return;
    }
    if (!updated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudieron guardar los niveles habilitados.'),
        ),
      );
      return;
    }

    ref.read(activeSetupSubmissionProvider.notifier).state = submission;
    setState(() {
      _enabledThemes = normalizedThemes;
      _draftEnabledThemes = [...normalizedThemes];
      _isEditingEnabledThemes = false;
      if (!_enabledThemes.contains(_selectedTheme)) {
        _selectedTheme = _enabledThemes.first;
      }
    });
  }

  Future<void> _handleBackAction() async {
    if (_isHandlingBackAction || !mounted) {
      return;
    }
    final controller = ref.read(matchControllerProvider);
    if (!controller.hasActiveMatch) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }
    _isHandlingBackAction = true;
    final decision = await showDialog<_CloseDecision>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Terminar partida'),
          content: const Text('Quieres terminar la partida actual?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(_CloseDecision.keep),
              child: const Text('Continuar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_CloseDecision.finish),
              child: const Text('Finalizar'),
            ),
          ],
        );
      },
    );
    _isHandlingBackAction = false;
    if (!mounted || decision != _CloseDecision.finish) {
      return;
    }
    await _finishMatch();
  }

  Future<void> _finishMatch() async {
    final submission =
        ref.read(activeSetupSubmissionProvider) ?? widget.submission;
    final result = await ref
        .read(matchControllerProvider)
        .finishMatchManually();
    if (!mounted || result == null) {
      return;
    }

    final navigator = Navigator.of(context);
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const HomePage(skipActiveMatchDialog: true),
      ),
      (route) => false,
    );
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => FinalJudgmentPage(
          submission: submission,
          scoresByPlayerId: result.scoresByPlayerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumAccessProvider);
    final session = ref.watch(matchSessionProvider);
    final activeSession = session != null && !session.isFinished
        ? session
        : null;
    final scoresByPlayerId = ref.watch(matchScoresProvider);
    final activeSubmission =
        ref.watch(activeSetupSubmissionProvider) ?? widget.submission;
    final completedRounds = activeSession?.completedRounds ?? 0;
    final currentParticipantId = activeSession?.currentParticipantId;
    final currentRound = activeSession?.roundNumber ?? 1;
    final currentPlayerName = resolveActivePlayerName(
      session: activeSession,
      submission: activeSubmission,
      activeParticipantId: currentParticipantId,
      fallback: ActivePlayerNameFallback.selection,
    );
    final modeAccent = activeSubmission.mode.isFriends
        ? const Color(0xFF0DAEFF)
        : const Color(0xFFFF4DA2);
    final modeSecondary = activeSubmission.mode.isFriends
        ? const Color(0xFF2C78FF)
        : const Color(0xFF8E4BFF);

    final availableToSpin = _order
        .where(_enabledThemes.contains)
        .where((theme) => isPremium || !theme.toMatchLevel.isPremium)
        .where(
          (theme) =>
              completedRounds >= theme.toMatchLevel.requiredCompletedRounds,
        )
        .toList(growable: false);
    final rouletteThemes = availableToSpin.isEmpty
        ? const <GameStyleTheme>[GameStyleTheme.cielo]
        : availableToSpin;
    final selectedThemeForUi = rouletteThemes.contains(_selectedTheme)
        ? _selectedTheme
        : rouletteThemes.first;
    if (selectedThemeForUi != _selectedTheme) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() => _selectedTheme = selectedThemeForUi);
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackAction();
        }
      },
      child: Scaffold(
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
                    const Color(0x35020512),
                    const Color(0xFF05070F).withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.15),
                  radius: 0.86,
                  colors: [
                    modeAccent.withValues(alpha: 0.28),
                    modeSecondary.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopHeader(
                      round: currentRound,
                      isFriendsMode: activeSubmission.mode.isFriends,
                      onBackTap: _handleBackAction,
                      onSettingsTap: _openSettings,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            currentPlayerName,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: modeAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 46 * 0.72,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Elige el nivel',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 29,
                                ),
                          ),
                          Text(
                            'que quieras jugar',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.82),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20 * 0.72,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: StartPointsRouletteWheel(
                        selectedTheme: selectedThemeForUi,
                        availableThemes: rouletteThemes,
                        hasPremiumAccess: isPremium,
                        isFriendsMode: activeSubmission.mode.isFriends,
                        modeAccent: modeAccent,
                        onThemeChanged: (theme) {
                          setState(() => _selectedTheme = theme);
                        },
                        onSpinCompleted: _openTruthOrDareSelectionPage,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _RiskEditRow(
                      isPremium: isPremium,
                      isEditing: _isEditingEnabledThemes,
                      onEditTap: _startEditingThemes,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 122,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final theme = _order[index];
                          final isEnabled = _isEditingEnabledThemes
                              ? _draftEnabledThemes.contains(theme)
                              : _enabledThemes.contains(theme);
                          final isRoundLocked =
                              completedRounds <
                              theme.toMatchLevel.requiredCompletedRounds;
                          final isPremiumLocked =
                              !isPremium && theme.toMatchLevel.isPremium;
                          return _LevelTile(
                            theme: theme,
                            isEnabled: isEnabled,
                            isEditing: _isEditingEnabledThemes,
                            isPremiumLocked: isPremiumLocked,
                            isRoundLocked: isRoundLocked,
                            onTap: () {
                              if (_isEditingEnabledThemes) {
                                _toggleDraftTheme(
                                  theme: theme,
                                  isPremium: isPremium,
                                );
                                return;
                              }
                              if (isPremiumLocked) {
                                final isGuest = !ref.read(
                                  isAuthenticatedProvider,
                                );
                                ref
                                    .read(analyticsServiceProvider)
                                    .logPremiumCtaViewed(
                                      source: 'start_points_edit_locked_theme',
                                      isGuest: isGuest,
                                      level: theme.toMatchLevel.name,
                                    );
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const PremiumMenuPage(),
                                  ),
                                );
                                return;
                              }
                              if (_enabledThemes.contains(theme)) {
                                setState(() => _selectedTheme = theme);
                              }
                            },
                          );
                        },
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemCount: _order.length,
                      ),
                    ),
                    if (_isEditingEnabledThemes) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _EditActions(
                        onConfirmTap: _confirmEnabledThemes,
                        onCancelTap: _cancelEditingThemes,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _PlayersSection(
                      submission: activeSubmission,
                      scoresByPlayerId: scoresByPlayerId,
                      currentParticipantId: currentParticipantId,
                      accentColor: modeAccent,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _BottomCardsHint(),
                  ],
                ),
              ),
            ),
            if (!isPremium)
              Positioned(
                top: 154,
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
                    isPremium: isPremium,
                    onTap: _onPremiumSlideTap,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _CloseDecision { keep, finish }

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.round,
    required this.isFriendsMode,
    required this.onBackTap,
    required this.onSettingsTap,
  });

  final int round;
  final bool isFriendsMode;
  final VoidCallback onBackTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          _HeaderCircleButton(
            onTap: onBackTap,
            child: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),
          const Spacer(),
          _RoundCapsule(round: round, isFriendsMode: isFriendsMode),
          const Spacer(),
          _HeaderCircleButton(
            onTap: onSettingsTap,
            child: Image.asset(
              'assets/menu-logo-icon-settings.png',
              width: 21,
              height: 21,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: PremiumGlassSurface(
          width: 60,
          height: 46,
          borderRadius: radius,
          gradientColors: const [Color(0x88353B51), Color(0x55313749)],
          borderColor: Colors.white.withValues(alpha: 0.34),
          innerBorderColor: Colors.white.withValues(alpha: 0.10),
          topHighlightOpacity: 0.22,
          bottomShadeOpacity: 0.20,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RoundCapsule extends StatelessWidget {
  const _RoundCapsule({required this.round, required this.isFriendsMode});

  final int round;
  final bool isFriendsMode;

  @override
  Widget build(BuildContext context) {
    final leftColor = isFriendsMode
        ? const Color(0xFF214C72)
        : const Color(0xFF6C2D5E);
    final midColor = isFriendsMode
        ? const Color(0xFF1D2E49)
        : const Color(0xFF4C2A5B);
    final rightColor = isFriendsMode
        ? const Color(0xFF262B3D)
        : const Color(0xFF2B233C);
    final capsuleBorder = isFriendsMode
        ? const Color(0xFF86C8FF)
        : const Color(0xFFF6A3CE);
    final badgeColor = isFriendsMode
        ? const Color(0xFF2B4866)
        : const Color(0xFF5A375E);

    return IntrinsicWidth(
      child: PremiumGlassSurface(
        height: 46,
        borderRadius: BorderRadius.circular(22),
        gradientBegin: Alignment.centerLeft,
        gradientEnd: Alignment.centerRight,
        gradientColors: [leftColor, midColor, rightColor],
        borderColor: capsuleBorder.withValues(alpha: 0.55),
        innerBorderColor: Colors.white.withValues(alpha: 0.10),
        topHighlightOpacity: 0.15,
        bottomShadeOpacity: 0.20,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeColor,
              ),
              alignment: Alignment.center,
              child: Text(
                '$round',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18 * 0.72,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Text(
              'Ronda',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 35 * 0.50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskEditRow extends StatelessWidget {
  const _RiskEditRow({
    required this.isPremium,
    required this.isEditing,
    required this.onEditTap,
  });

  final bool isPremium;
  final bool isEditing;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '✨ Escoge el nivel bajo tu propio riesgo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ),
        if (isPremium && !isEditing)
          OutlinedButton.icon(
            onPressed: onEditTap,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 28),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
              foregroundColor: Colors.white.withValues(alpha: 0.92),
              textStyle: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 0),
            ),
            icon: const Icon(Icons.edit_outlined, size: 12),
            label: const Text('Editar'),
          ),
      ],
    );
  }
}

class _EditActions extends StatelessWidget {
  const _EditActions({required this.onConfirmTap, required this.onCancelTap});

  final VoidCallback onConfirmTap;
  final VoidCallback onCancelTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: onConfirmTap,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(140, 38),
            side: const BorderSide(color: Color(0xFF00E06E), width: 1),
            foregroundColor: Colors.white,
            backgroundColor: const Color(0x1C00E06E),
            shape: const StadiumBorder(),
          ),
          child: const Text('Confirmar'),
        ),
        const SizedBox(width: AppSpacing.md),
        OutlinedButton(
          onPressed: onCancelTap,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(140, 38),
            side: const BorderSide(color: Color(0xFFFF3348), width: 1),
            foregroundColor: Colors.white,
            backgroundColor: const Color(0x1EFF3348),
            shape: const StadiumBorder(),
          ),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.theme,
    required this.isEnabled,
    required this.isEditing,
    required this.isPremiumLocked,
    required this.isRoundLocked,
    required this.onTap,
  });

  final GameStyleTheme theme;
  final bool isEnabled;
  final bool isEditing;
  final bool isPremiumLocked;
  final bool isRoundLocked;
  final VoidCallback onTap;

  String get _asset => switch (theme) {
    GameStyleTheme.cielo => 'assets/cielo-icon-logo.png',
    GameStyleTheme.tierra => 'assets/tierra-icon-logo.png',
    GameStyleTheme.infierno => 'assets/infierno-icon-logo.png',
    GameStyleTheme.inframundo => 'assets/inframundo-icon-logo.png',
  };

  @override
  Widget build(BuildContext context) {
    final enabledGlow = isPremiumLocked
        ? null
        : isEnabled
        ? theme.accentColor.withValues(alpha: 0.40)
        : null;
    final borderColor = isPremiumLocked
        ? Colors.black.withValues(alpha: 0.20)
        : isEnabled
        ? theme.accentColor
        : Colors.black.withValues(alpha: 0.20);
    final title = _titleFor(theme);
    final subtitle = '+${theme.toMatchLevel.points} puntos';
    final opacity = isPremiumLocked ? 0.78 : 1.0;
    final lockedTop = const Color(0xFF2B2D33);
    final lockedBottom = const Color(0xFF181A1F);
    final baseTop = isPremiumLocked ? lockedTop : const Color(0xF61A1B22);
    final baseBottom = isPremiumLocked ? lockedBottom : const Color(0xE10B0D14);
    final bottomTintStrong = isPremiumLocked || !isEnabled
        ? Colors.transparent
        : theme.accentColor.withValues(alpha: isEnabled ? 0.34 : 0.14);
    final bottomTintSoft = isPremiumLocked || !isEnabled
        ? Colors.transparent
        : theme.accentColor.withValues(alpha: isEnabled ? 0.16 : 0.06);
    final topShadowStrong = isPremiumLocked ? 0.38 : 0.46;
    final topShadowSoft = isPremiumLocked ? 0.20 : 0.25;
    final topLineColor = isPremiumLocked
        ? Colors.white.withValues(alpha: 0.10)
        : theme.accentColor.withValues(alpha: isEnabled ? 0.30 : 0.14);
    final titleColor = isPremiumLocked
        ? Colors.white.withValues(alpha: 0.78)
        : Colors.white;
    final subtitleColor = isPremiumLocked
        ? Colors.white.withValues(alpha: 0.58)
        : Colors.white.withValues(alpha: 0.78);

    return Opacity(
      opacity: opacity,
      child: VerticalLevelCardFrame(
        onTap: onTap,
        borderColor: borderColor,
        borderThickness: isEnabled ? 2.5 : 1,
        baseTopColor: baseTop,
        baseBottomColor: baseBottom,
        bottomTintStrong: bottomTintStrong,
        bottomTintSoft: bottomTintSoft,
        topLineColor: topLineColor,
        topShadowStrongAlpha: topShadowStrong,
        topShadowSoftAlpha: topShadowSoft,
        glowColor: enabledGlow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 13),
            SizedBox(
              height: 38,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      alignment: Alignment.center,
                      width: 36,
                      height: 36,
                      padding: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        color: isPremiumLocked
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: isPremiumLocked || !isEnabled
                          ? ColorFiltered(
                              colorFilter: const ColorFilter.matrix(<double>[
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ]),
                              child: Image.asset(_asset, fit: BoxFit.contain),
                            )
                          : Image.asset(_asset, fit: BoxFit.contain),
                    ),
                  ),
                  if (isEditing)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: isEnabled
                          ? Image.asset(
                              'assets/logo-icon-checked.png',
                              width: 14,
                              height: 14,
                              fit: BoxFit.contain,
                              color: Colors.white.withValues(alpha: 0.96),
                            )
                          : Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  width: 3.2,
                                ),
                              ),
                            ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
            ),
            Center(
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 9),
          ],
        ),
      ),
    );
  }

  String _titleFor(GameStyleTheme theme) {
    return switch (theme) {
      GameStyleTheme.cielo => 'Cielo',
      GameStyleTheme.tierra => 'Tierra',
      GameStyleTheme.infierno => 'Infierno',
      GameStyleTheme.inframundo => 'Inframundo',
    };
  }
}

class _PlayersSection extends StatelessWidget {
  const _PlayersSection({
    required this.submission,
    required this.scoresByPlayerId,
    required this.currentParticipantId,
    required this.accentColor,
  });

  final GameSetupSubmission submission;
  final Map<int, int> scoresByPlayerId;
  final int? currentParticipantId;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final players = submission.players
        .map(
          (player) => _ScorePlayer(
            id: player.id,
            name: player.name.trim().isEmpty
                ? 'Jugador ${player.id}'
                : player.name.trim(),
            avatarAssetPath: player.avatarAssetPath,
            points: scoresByPlayerId[player.id] ?? 0,
            isActive: currentParticipantId == player.id,
            pairIndex: player.pairIndex,
          ),
        )
        .toList(growable: false);
    final playersById = <int, _ScorePlayer>{
      for (final player in players) player.id: player,
    };
    final pairGroups = _buildPairGroups(playersById: playersById);
    final showGroupedPairs = submission.mode.isCouples && pairGroups.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Jugadores',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 19,
              ),
            ),
            const Spacer(),
            Text(
              showGroupedPairs
                  ? '${pairGroups.length} parejas'
                  : '${players.length} jugadores',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (showGroupedPairs)
          SizedBox(
            height: 238,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemBuilder: (context, index) => _CouplePlayersGroupCard(
                group: pairGroups[index],
                accentColor: accentColor,
              ),
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemCount: pairGroups.length,
            ),
          )
        else
          SizedBox(
            height: 74,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemBuilder: (context, index) =>
                  _PlayerChip(player: players[index], accentColor: accentColor),
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemCount: players.length,
            ),
          ),
      ],
    );
  }

  List<_ScorePairGroup> _buildPairGroups({
    required Map<int, _ScorePlayer> playersById,
  }) {
    final pairSources = submission.pairs
        .where((pair) => pair.isNotEmpty)
        .toList(growable: false);
    final groups = <_ScorePairGroup>[];

    if (pairSources.isNotEmpty) {
      for (var i = 0; i < pairSources.length; i++) {
        final pair = pairSources[i];
        final members = pair
            .map((player) => playersById[player.id])
            .whereType<_ScorePlayer>()
            .toList(growable: false);
        if (members.isEmpty) {
          continue;
        }
        final pairNumber = (pair.first.pairIndex ?? i) + 1;
        groups.add(_ScorePairGroup(pairNumber: pairNumber, members: members));
      }
    }

    if (groups.isEmpty) {
      final groupedByPair = <int, List<_ScorePlayer>>{};
      for (final player in playersById.values) {
        final key = player.pairIndex ?? ((player.id - 1) ~/ 2);
        groupedByPair.putIfAbsent(key, () => <_ScorePlayer>[]).add(player);
      }
      final sortedKeys = groupedByPair.keys.toList(growable: false)..sort();
      for (final key in sortedKeys) {
        groups.add(
          _ScorePairGroup(pairNumber: key + 1, members: groupedByPair[key]!),
        );
      }
    }

    groups.sort((a, b) => a.pairNumber.compareTo(b.pairNumber));
    return groups;
  }
}

class _PlayerChip extends StatelessWidget {
  const _PlayerChip({required this.player, required this.accentColor});

  final _ScorePlayer player;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final borderShadowColor = player.isActive
        ? accentColor.withValues(alpha: 0.28)
        : Colors.white.withValues(alpha: 0.10);
    final chipRadius = BorderRadius.circular(999);

    return Container(
      constraints: const BoxConstraints(minWidth: 146),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: chipRadius,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xE7191B24), Color(0xDD0A0C14)],
        ),
        border: Border.all(
          color: player.isActive
              ? accentColor.withValues(alpha: 0.96)
              : Colors.white.withValues(alpha: 0.10),
          width: player.isActive ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: borderShadowColor,
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
          if (player.isActive)
            BoxShadow(
              color: accentColor.withValues(alpha: 0.40),
              spreadRadius: -0.4,
              blurRadius: 16,
              offset: Offset.zero,
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: ClipOval(
              child: Image.asset(player.avatarAssetPath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                player.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
              Row(
                children: [
                  Image.asset(
                    'assets/logo-icon-start-points.png',
                    width: 12,
                    height: 12,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${player.points} puntos',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CouplePlayersGroupCard extends StatelessWidget {
  const _CouplePlayersGroupCard({
    required this.group,
    required this.accentColor,
  });

  final _ScorePairGroup group;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isActiveGroup = group.members.any((member) => member.isActive);
    final borderColor = isActiveGroup
        ? accentColor.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.10);

    return Container(
      width: 196,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xE815171F), Color(0xD90A0C13)],
        ),
        border: Border.all(color: borderColor, width: isActiveGroup ? 1.2 : 1),
        boxShadow: [
          if (isActiveGroup)
            BoxShadow(
              color: accentColor.withValues(alpha: 0.28),
              blurRadius: 20,
              spreadRadius: -1,
              offset: Offset.zero,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pareja ${group.pairNumber}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.94),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < group.members.length; i++) ...[
            _PairMemberChip(player: group.members[i], accentColor: accentColor),
            if (i != group.members.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _PairMemberChip extends StatelessWidget {
  const _PairMemberChip({required this.player, required this.accentColor});

  final _ScorePlayer player;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final borderColor = player.isActive
        ? accentColor.withValues(alpha: 0.96)
        : Colors.white.withValues(alpha: 0.10);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xC2181B24), Color(0xB50C101A)],
        ),
        border: Border.all(
          color: borderColor,
          width: player.isActive ? 1.2 : 1,
        ),
        boxShadow: [
          if (player.isActive)
            BoxShadow(
              color: accentColor.withValues(alpha: 0.42),
              blurRadius: 16,
              spreadRadius: -1,
              offset: Offset.zero,
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: ClipOval(
              child: Image.asset(player.avatarAssetPath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 9),
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
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                Row(
                  children: [
                    Image.asset(
                      'assets/logo-icon-start-points.png',
                      width: 12,
                      height: 12,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${player.points} puntos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.80),
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

class _BottomCardsHint extends StatelessWidget {
  const _BottomCardsHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xDD242839), Color(0xCC141728)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFB08A11).withValues(alpha: 0.28),
            ),
            child: Image.asset(
              'assets/logo-icon-foco-premium.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'El nivel define la intensidad de las cartas que saldrán.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.90),
                fontWeight: FontWeight.w500,
                fontSize: 24 * 0.58,
                height: 1.24,
              ),
            ),
          ),
          Image.asset(
            'assets/logo-icon-cards-levels.png',
            width: 106,
            fit: BoxFit.contain,
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
    required this.avatarAssetPath,
    required this.points,
    required this.isActive,
    required this.pairIndex,
  });

  final int id;
  final String name;
  final String avatarAssetPath;
  final int points;
  final bool isActive;
  final int? pairIndex;
}

class _ScorePairGroup {
  const _ScorePairGroup({required this.pairNumber, required this.members});

  final int pairNumber;
  final List<_ScorePlayer> members;
}
