import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'tutorial_shared.dart';

class TutorialThirdView extends StatelessWidget {
  const TutorialThirdView({super.key});

  @override
  Widget build(BuildContext context) {
    return TutorialBackground(
      assetPath: 'assets/background-tutorial-3.png',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            Image.asset('assets/logo-simple.png', width: 170),
            const SizedBox(height: AppSpacing.lg),
            Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
                children: const [
                  TextSpan(text: '4 '),
                  TextSpan(
                    text: 'NIVELES',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tú decides qué tan lejos llegas.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _TutorialLevelCard(
              cardIndex: 0,
              borderColor: AppColors.secondary,
              titleColor: AppColors.secondary,
              iconAsset: 'assets/cielo-icon-logo.png',
              characterAsset: 'assets/tutorial-3-cielo.png',
              levelName: 'CIELO',
              trailingLabel: 'Gratis',
              description: 'Todo empieza suave. Confianza ligera.',
              characterOnLeft: true,
            ),
            const SizedBox(height: AppSpacing.xxl),
            const _TutorialLevelCard(
              cardIndex: 1,
              borderColor: Color(0xFF00D359),
              titleColor: Color(0xFF00D359),
              iconAsset: 'assets/tierra-icon-logo.png',
              characterAsset: 'assets/tutorial-3-tierra.png',
              levelName: 'TIERRA',
              badgeText: 'Premium',
              description:
                  'Las preguntas ya pesan. Empiezan las miradas raras.',
              cardHeight: 132,
            ),
            const SizedBox(height: AppSpacing.xxl),
            const _TutorialLevelCard(
              cardIndex: 2,
              borderColor: Color(0xFFFF2B2B),
              titleColor: Color(0xFFFF2B2B),
              iconAsset: 'assets/infierno-icon-logo.png',
              characterAsset: 'assets/tutorial-3-infierno.png',
              levelName: 'INFIERNO',
              badgeText: 'Premium',
              description: 'Aquí se hacen cositas que no se olvidan.',
              highlightText: 'Se pone muy picante.',
              characterOnLeft: true,
              cardHeight: 140,
            ),
            const SizedBox(height: AppSpacing.xxl),
            const _TutorialLevelCard(
              cardIndex: 3,
              borderColor: Color(0xFFB02DFF),
              titleColor: Color(0xFFC246FF),
              iconAsset: 'assets/inframundo-icon-logo.png',
              characterAsset: 'assets/tutorial-3-inframundo.png',
              levelName: 'INFRAMUNDO',
              badgeText: 'Premium',
              showNewBadge: true,
              description:
                  'No hay filtros.\nNo hay excusas.\nSolo personas que se atreven...',
              highlightText:
                  'Aquí no puedes decir NO a nada o te sales del juego',
              characterWidth: 148,
              cardHeight: 182,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Una vez bajas... no vuelves igual.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialLevelCard extends StatelessWidget {
  const _TutorialLevelCard({
    required this.cardIndex,
    required this.borderColor,
    required this.titleColor,
    required this.iconAsset,
    required this.characterAsset,
    required this.levelName,
    required this.description,
    this.highlightText,
    this.trailingLabel,
    this.badgeText,
    this.showNewBadge = false,
    this.characterOnLeft = false,
    this.characterWidth = 98,
    this.cardHeight = 128,
  });

  final int cardIndex;
  final Color borderColor;
  final Color titleColor;
  final String iconAsset;
  final String characterAsset;
  final String levelName;
  final String description;
  final String? highlightText;
  final String? trailingLabel;
  final String? badgeText;
  final bool showNewBadge;
  final bool characterOnLeft;
  final double characterWidth;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    final isInframundo = levelName == 'INFRAMUNDO';
    final isInfierno = levelName == 'INFIERNO';
    final leftCharacterOffset = isInfierno
        ? const Offset(-15, 3)
        : const Offset(5, 0);
    final leftCharacterHeight = isInfierno
        ? characterWidth * 1.5
        : characterWidth * 1.3;
    final rightCharacterOffset = isInframundo
        ? const Offset(3, 0)
        : const Offset(8, 0);
    final rightCharacterHeight = isInframundo
        ? characterWidth * 1.3
        : characterWidth * 1.5;
    const outerRadius = 20.0;
    const borderThickness = 1.35;
    const borderStops = [0.0, 0.28, 0.62, 1.0];
    final iconSquareColor = switch (levelName) {
      'TIERRA' => const Color(0xFF0B9E3F),
      'INFIERNO' => const Color(0xFFC31212),
      _ => Colors.white.withValues(alpha: 0.08),
    };

    return SizedBox(
      height: cardHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(outerRadius),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  borderColor.withValues(alpha: 0.35),
                  borderColor.withValues(alpha: 0.22),
                  borderColor.withValues(alpha: 0.16),
                  borderColor.withValues(alpha: 0.0),
                ],
                stops: borderStops,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(borderThickness),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  outerRadius - borderThickness,
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xE61A1B21), Color(0xE6000000)],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          outerRadius - borderThickness,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: const Alignment(-1, 0),
                          colors: [
                            borderColor.withValues(alpha: 0.18),
                            borderColor.withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.52, 0.88],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (characterOnLeft) SizedBox(width: characterWidth),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            characterOnLeft ? 20 : 14,
                            12,
                            characterOnLeft ? 14 : 8,
                            12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TutorialIconSquare(
                                    iconAsset: iconAsset,
                                    backgroundColor: iconSquareColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(height: 1.05),
                                        children: [
                                          const TextSpan(
                                            text: 'Nivel\n',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          TextSpan(
                                            text: levelName,
                                            style: TextStyle(
                                              color: titleColor,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 33 / 1.55,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (trailingLabel != null)
                                    Text(
                                      trailingLabel!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(fontSize: 13, height: 1.08),
                                    children: [
                                      TextSpan(text: description),
                                      if (highlightText != null) ...[
                                        const TextSpan(text: '\n'),
                                        TextSpan(
                                          text: highlightText!,
                                          style: TextStyle(
                                            color: titleColor,
                                            fontWeight: FontWeight.w700,
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
                      if (!characterOnLeft)
                        SizedBox(width: characterWidth - 30),
                    ],
                  ),
                  if (characterOnLeft)
                    Positioned(
                      left: 0,
                      bottom: 0,
                      width: characterWidth,
                      height: leftCharacterHeight,
                      child: _AnimatedTutorialCharacter(
                        fromLeft: true,
                        delayMs: 120 + (cardIndex * 140),
                        child: Transform.translate(
                          offset: leftCharacterOffset,
                          child: OverflowBox(
                            minWidth: characterWidth,
                            maxWidth: characterWidth * 2.2,
                            minHeight: leftCharacterHeight,
                            maxHeight: leftCharacterHeight,
                            alignment: Alignment.bottomLeft,
                            child: Image.asset(
                              characterAsset,
                              height: leftCharacterHeight,
                              fit: BoxFit.fitHeight,
                              alignment: Alignment.bottomLeft,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!characterOnLeft)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      width: characterWidth,
                      height: rightCharacterHeight,
                      child: _AnimatedTutorialCharacter(
                        fromLeft: false,
                        delayMs: 120 + (cardIndex * 140),
                        child: Transform.translate(
                          offset: rightCharacterOffset,
                          child: OverflowBox(
                            minWidth: characterWidth,
                            maxWidth: characterWidth * 2.2,
                            minHeight: rightCharacterHeight,
                            maxHeight: rightCharacterHeight,
                            alignment: Alignment.bottomRight,
                            child: Image.asset(
                              characterAsset,
                              height: rightCharacterHeight,
                              fit: BoxFit.fitHeight,
                              alignment: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (badgeText != null)
            isInfierno
                ? Positioned(
                    top: -12,
                    right: 12,
                    child: _TutorialPremiumBadge(text: badgeText!),
                  )
                : Positioned(
                    top: -12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _TutorialPremiumBadge(text: badgeText!),
                    ),
                  ),
          if (showNewBadge)
            const Positioned(top: -8, left: -6, child: _TutorialNewBadge()),
        ],
      ),
    );
  }
}

class _AnimatedTutorialCharacter extends StatefulWidget {
  const _AnimatedTutorialCharacter({
    required this.child,
    required this.fromLeft,
    required this.delayMs,
  });

  final Widget child;
  final bool fromLeft;
  final int delayMs;

  @override
  State<_AnimatedTutorialCharacter> createState() =>
      _AnimatedTutorialCharacterState();
}

class _AnimatedTutorialCharacterState
    extends State<_AnimatedTutorialCharacter> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final hiddenOffset = widget.fromLeft
        ? const Offset(-0.22, 0.08)
        : const Offset(0.22, 0.08);
    return AnimatedSlide(
      offset: _visible ? Offset.zero : hiddenOffset,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _TutorialPremiumBadge extends StatelessWidget {
  const _TutorialPremiumBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDE8D00),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/premium-icon-logo.png',
            width: 18,
            height: 12,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              fontSize: 17 / 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialNewBadge extends StatelessWidget {
  const _TutorialNewBadge();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.45,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            colors: [Color(0xFF8B1EFF), Color(0xFFE82676)],
          ),
        ),
        child: Text(
          'Nuevo',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15 / 1.35,
          ),
        ),
      ),
    );
  }
}
