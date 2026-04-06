import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_3d_pill_button.dart';
import '../../../game_mode_selection/presentation/pages/home_page.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../../../player_setup/presentation/pages/player_setup_page.dart';
import '../../../player_setup/presentation/widgets/premium_glass_surface.dart';

class FinalProphecyChallengeModePage extends StatefulWidget {
  const FinalProphecyChallengeModePage({
    required this.submission,
    required this.punishedLabel,
    required this.challengeText,
    this.onPlayAgainTap,
    this.onBackToHomeTap,
    super.key,
  });

  final GameSetupSubmission submission;
  final String punishedLabel;
  final String challengeText;
  final VoidCallback? onPlayAgainTap;
  final VoidCallback? onBackToHomeTap;

  @override
  State<FinalProphecyChallengeModePage> createState() =>
      _FinalProphecyChallengeModePageState();
}

class _FinalProphecyChallengeModePageState
    extends State<FinalProphecyChallengeModePage> {
  bool get _isFriendsMode => widget.submission.mode.isFriends;

  Color get _modeAccent =>
      _isFriendsMode ? const Color(0xFF2A9DFF) : const Color(0xFFE94494);

  String get _backgroundAsset => _isFriendsMode
      ? 'assets/background-setup-friends-mode.png'
      : 'assets/background-setup-couple-mode.png';

  List<Color> get _modeButtonGradient => _isFriendsMode
      ? const [Color(0xFF5FC0FF), Color(0xFF2E6FC9)]
      : const [Color(0xFFF574B9), Color(0xFFD93D88)];

  void _defaultPlayAgain() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => PlayerSetupPage(mode: widget.submission.mode),
      ),
      (route) => false,
    );
  }

  void _defaultBackToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                radius: 0.9,
                colors: [
                  (_isFriendsMode
                          ? const Color(0xFF2562B8)
                          : const Color(0xFFB90E32))
                      .withValues(alpha: 0.52),
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
                        _HeaderSideButton(
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
                            '${widget.punishedLabel} deberá cumplir el castigo\n'
                            'elegido por...',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 34 * 0.56,
                                  height: 1.14,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: const Color(
                                0xFF171A21,
                              ).withValues(alpha: 0.92),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.09),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Reto de la profecía',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.94),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 30 * 0.58,
                                  ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _modeAccent.withValues(alpha: 0.44),
                                  blurRadius: 22,
                                  spreadRadius: 0.6,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.26),
                                  blurRadius: 14,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: PremiumGlassSurface(
                              height: 266,
                              borderRadius: BorderRadius.circular(20),
                              gradientColors: [
                                const Color(0xFF25262B).withValues(alpha: 0.88),
                                (_isFriendsMode
                                        ? const Color(0xFF1F3F5C)
                                        : const Color(0xFF4A2943))
                                    .withValues(alpha: 0.86),
                              ],
                              borderColor: _modeAccent.withValues(alpha: 0.66),
                              innerBorderColor: _modeAccent.withValues(
                                alpha: 0.24,
                              ),
                              topHighlightOpacity: 0.14,
                              bottomShadeOpacity: 0.2,
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.md,
                                AppSpacing.md,
                                AppSpacing.md,
                                AppSpacing.md,
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Image.asset(
                                        'assets/logo-icon-juicio-final-kiss.png',
                                        width: 184,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.black.withValues(
                                        alpha: 0.62,
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.08,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      widget.challengeText,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.94,
                                            ),
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.italic,
                                            fontSize: 38 * 0.56,
                                            height: 1.12,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          App3dPillButton(
                            label: 'Jugar de nuevo',
                            color: const Color(0xFFE9EBF1),
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
                            onTap: widget.onPlayAgainTap ?? _defaultPlayAgain,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          App3dPillButton(
                            label: 'Volver al inicio',
                            color: _modeButtonGradient.first,
                            gradientColors: _modeButtonGradient,
                            height: 62,
                            depth: 4.4,
                            borderRadius: 16,
                            textStyle: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 32 * 0.58,
                                ),
                            onTap: widget.onBackToHomeTap ?? _defaultBackToHome,
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

class _HeaderSideButton extends StatelessWidget {
  const _HeaderSideButton({required this.accent, required this.onTap});

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
