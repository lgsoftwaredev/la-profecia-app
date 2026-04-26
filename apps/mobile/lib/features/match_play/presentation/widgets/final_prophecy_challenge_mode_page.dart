import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_3d_pill_button.dart';
import '../../../game_mode_selection/presentation/pages/home_page.dart';
import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../../../player_setup/presentation/pages/player_setup_page.dart';
import 'match_timer_chip.dart';

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
  State<FinalProphecyChallengeModePage> createState() => _FinalProphecyChallengeModePageState();
}

class _FinalProphecyChallengeModePageState extends State<FinalProphecyChallengeModePage> {
  static const _initialTimerSeconds = 300;
  static const _primaryButtonGradient = [Color(0xFFFA402B), Color(0xFFB71812)];

  Timer? _timerTicker;
  var _remainingTimerSeconds = _initialTimerSeconds;

  void _defaultPlayAgain() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => PlayerSetupPage(mode: widget.submission.mode)),
      (route) => false,
    );
  }

  void _defaultBackToHome() {
    Navigator.of(
      context,
    ).pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => const HomePage()), (route) => false);
  }

  void _onTimerTap() {
    if (_remainingTimerSeconds <= 0) {
      return;
    }
    if (_timerTicker != null) {
      _timerTicker?.cancel();
      _timerTicker = null;
      setState(() {});
      return;
    }

    _timerTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingTimerSeconds <= 1) {
        timer.cancel();
        _timerTicker = null;
        setState(() {
          _remainingTimerSeconds = 0;
        });
        return;
      }
      setState(() {
        _remainingTimerSeconds -= 1;
      });
    });
    setState(() {});
  }

  @override
  void dispose() {
    _timerTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _RedFinalChallengeBackground(),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.sm),
                        const _ChallengeTypePill(text: 'Reto de La Profecía'),
                        const SizedBox(height: AppSpacing.lg),
                        const _ChallengeHeroIcon(),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          widget.punishedLabel,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 23,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Debe cumplir el castigo',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.94),
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: _ProphecyChallengePanel(challengeText: widget.challengeText),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Center(
                                child: MatchTimerChip(
                                  seconds: _remainingTimerSeconds,
                                  accent: const Color(0xFFE6422E),
                                  onTap: _onTimerTap,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: App3dPillButton(
                                label: 'Jugar de nuevo',
                                color: const Color(0xFFE9EBF1),
                                gradientColors: const [Color(0xFFF7F8FA), Color(0xFFE4E7EE)],
                                height: 62,
                                depth: 4.4,
                                borderRadius: 22,
                                textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: const Color(0xFF3C465D),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 33 * 0.58,
                                ),
                                onTap: widget.onPlayAgainTap ?? _defaultPlayAgain,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: App3dPillButton(
                                label: 'Volver al inicio',
                                color: _primaryButtonGradient.first,
                                gradientColors: _primaryButtonGradient,
                                height: 62,
                                depth: 4.4,
                                borderRadius: 22,
                                textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 33 * 0.58,
                                ),
                                onTap: widget.onBackToHomeTap ?? _defaultBackToHome,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Gracias por jugar, nos vemos pronto',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.52),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl * 3.15),

                      ],
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

class _TopBackButton extends StatelessWidget {
  const _TopBackButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: Ink(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
            ),
            child: Icon(Icons.chevron_left_rounded, color: Colors.white.withValues(alpha: 0.95), size: 28),
          ),
        ),
      ),
    );
  }
}

class _ChallengeTypePill extends StatelessWidget {
  const _ChallengeTypePill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xE616161D), Color(0xD0121218)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      alignment: Alignment.center,
      child: Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Reto de ',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              TextSpan(
                text: 'La Profecía',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFFFA402B)),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ChallengeHeroIcon extends StatelessWidget {
  const _ChallengeHeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFCC2317), width: 1.4),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F222B), Color(0xFF0D0E13)],
        ),
      ),
      child: Center(
        child: Image.asset('assets/logo-icon-judgment-prophecy-or-group.png', width: 88, fit: BoxFit.contain),
      ),
    );
  }
}

class _ProphecyChallengePanel extends StatelessWidget {
  const _ProphecyChallengePanel({required this.challengeText});

  final String challengeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl + 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA20D12), Color(0xFF4A070C)],
        ),
        border: Border.all(color: const Color(0xFFE43B2A), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3F2E).withValues(alpha: 0.24),
            blurRadius: 26,
            spreadRadius: 0.6,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SizedBox(
        height: 185,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              left: 58,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF5A1010), Color(0xFF2B0608)],
                  ),
                  border: Border.all(
                    color: const Color(0xFFE43B2A),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    challengeText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.94),
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          fontSize: 38 * 0.56,
                          height: 1.12,
                        ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -6,
              top:0,
              bottom: 0,
              child: Image.asset(
                'assets/logo-icon-judgment-prophecy-or-group.png',
                width: 130,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RedFinalChallengeBackground extends StatelessWidget {
  const _RedFinalChallengeBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF12010A), Color(0xFF220108), Color(0xFF07020C)],
              stops: [0, 0.56, 1],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.08),
              radius: 1.08,
              colors: [
                const Color(0xFFFF2A1B).withValues(alpha: 0.46),
                const Color(0xFFB90E17).withValues(alpha: 0.24),
                Colors.transparent,
              ],
              stops: const [0.0, 0.48, 0.95],
            ),
          ),
        ),
      ],
    );
  }
}
