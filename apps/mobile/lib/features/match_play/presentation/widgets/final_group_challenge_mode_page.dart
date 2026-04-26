import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_3d_pill_button.dart';
import '../../../game_mode_selection/presentation/pages/home_page.dart';
import '../../../player_setup/domain/entities/game_setup_models.dart';
import '../../../player_setup/presentation/pages/player_setup_page.dart';
import 'match_timer_chip.dart';

class FinalGroupChallengeModePage extends ConsumerStatefulWidget {
  const FinalGroupChallengeModePage({
    required this.submission,
    required this.punishedLabel,
    this.onSendTap,
    this.onPlayAgainTap,
    this.onBackToHomeTap,
    this.onSuccessTap,
    this.titleText,
    this.subtitleText,
    this.actorLabelText,
    this.inputHintText,
    this.sendButtonLabel = 'Enviar',
    this.showReplayActions = true,
    this.showDefaultFailureMessage = true,
    super.key,
  });

  final GameSetupSubmission submission;
  final String punishedLabel;
  final Future<bool> Function(String)? onSendTap;
  final VoidCallback? onPlayAgainTap;
  final VoidCallback? onBackToHomeTap;
  final VoidCallback? onSuccessTap;
  final String? titleText;
  final String? subtitleText;
  final String? actorLabelText;
  final String? inputHintText;
  final String sendButtonLabel;
  final bool showReplayActions;
  final bool showDefaultFailureMessage;

  @override
  ConsumerState<FinalGroupChallengeModePage> createState() =>
      _FinalGroupChallengeModePageState();
}

class _FinalGroupChallengeModePageState
    extends ConsumerState<FinalGroupChallengeModePage> {
  static const _initialTimerSeconds = 300;
  static const _primaryButtonGradient = [Color(0xFFFA402B), Color(0xFFB71812)];
  static const _tooltipText =
      'Puedes enviar el reto que propones para el perdedor. Lo evaluaremos y, si queda seleccionado, lo incluiremos en el juego y aparecerás en la tabla global con los mejores retos.';

  final _penaltyController = TextEditingController();
  Timer? _timerTicker;
  var _remainingTimerSeconds = _initialTimerSeconds;
  var _isSending = false;

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

  Future<void> _handleSend() async {
    if (_isSending) {
      return;
    }

    final text = _penaltyController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un castigo primero.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    final success =
        await (widget.onSendTap?.call(text) ??
            ref.read(matchControllerProvider).saveFinalGroupPenalty(text));
    if (!mounted) {
      return;
    }

    FocusScope.of(context).unfocus();
    if (success) {
      final onSuccessTap = widget.onSuccessTap;
      if (onSuccessTap != null) {
        onSuccessTap();
        return;
      }
      if (widget.showReplayActions) {
        _defaultPlayAgain();
        return;
      }
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }

    setState(() {
      _isSending = false;
    });
    if (widget.showDefaultFailureMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar, debes iniciar sesión.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timerTicker?.cancel();
    _penaltyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challengeLabel =
        widget.actorLabelText ?? widget.titleText ?? 'Reto del grupo';
    final subtitle = widget.subtitleText ?? 'Debe cumplir el castigo';

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
                  const _TopBackButton(),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.sm),
                          _ChallengeTypePill(text: challengeLabel),
                          const SizedBox(height: AppSpacing.lg),
                          const _ChallengeHeroIcon(),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            widget.punishedLabel,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 25,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
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
                                padding: const EdgeInsets.only(top: 16),
                                child: _GroupChallengeInputPanel(
                                  controller: _penaltyController,
                                  tooltipText: _tooltipText,
                                  hintText:
                                      widget.inputHintText ??
                                      'Escribe el castigo',
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
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
                          const SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            width: 170,
                            child: App3dPillButton(
                              label: widget.sendButtonLabel,
                              color: _primaryButtonGradient.first,
                              gradientColors: _primaryButtonGradient,
                              height: 54,
                              depth: 4,
                              borderRadius: 18,
                              isLoading: _isSending,
                              textStyle: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 34 * 0.58,
                                  ),
                              onTap: _isSending ? null : _handleSend,
                            ),
                          ),
                          if (widget.showReplayActions) ...[
                            const SizedBox(height: AppSpacing.xl * 1.3),
                            Row(
                              children: [
                                Expanded(
                                  child: App3dPillButton(
                                    label: 'Jugar de nuevo',
                                    color: const Color(0xFFE9EBF1),
                                    gradientColors: const [
                                      Color(0xFFF7F8FA),
                                      Color(0xFFE4E7EE),
                                    ],
                                    height: 62,
                                    depth: 4.4,
                                    borderRadius: 22,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: const Color(0xFF3C465D),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 33 * 0.58,
                                        ),
                                    onTap:
                                        widget.onPlayAgainTap ??
                                        _defaultPlayAgain,
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
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 33 * 0.58,
                                        ),
                                    onTap:
                                        widget.onBackToHomeTap ??
                                        _defaultBackToHome,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Gracias por jugar, nos vemos pronto',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.52),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                  ),
                            ),
                          ],
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
            child: Icon(
              Icons.chevron_left_rounded,
              color: Colors.white.withValues(alpha: 0.95),
              size: 28,
            ),
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
      width: 210,
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
                text: 'Reto del ',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              TextSpan(
                text: 'ganador',
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
        child: Image.asset(
          'assets/logo-icon-judgment-prophecy-or-group.png',
          width: 88,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _GroupChallengeInputPanel extends StatelessWidget {
  const _GroupChallengeInputPanel({
    required this.controller,
    required this.tooltipText,
    required this.hintText,
  });

  final TextEditingController controller;
  final String tooltipText;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xl + 2,
        AppSpacing.md,
        AppSpacing.md,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  left: 72,
                  child: Container(
                    height: 168,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF8A1D1D), Color(0xFF5F1010)],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 28 * 0.6,
                            fontWeight: FontWeight.w500,
                          ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 31 * 0.56,
                                  fontWeight: FontWeight.w400,
                                ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
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
          const SizedBox(height: AppSpacing.xs),
          Tooltip(
            message: tooltipText,
            triggerMode: TooltipTriggerMode.tap,
            waitDuration: Duration.zero,
            showDuration: const Duration(seconds: 5),
            preferBelow: false,
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12.5,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.80),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.info_rounded,
              color: Colors.white.withValues(alpha: 0.84),
              size: 22,
            ),
          ),
        ],
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
