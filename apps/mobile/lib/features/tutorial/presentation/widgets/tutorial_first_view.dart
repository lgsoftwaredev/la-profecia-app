import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'tutorial_shared.dart';

class TutorialFirstView extends StatelessWidget {
  const TutorialFirstView({super.key});

  @override
  Widget build(BuildContext context) {
    return const TutorialBackground(
      videoAssetPath: 'assets/videos/tutorial-1-pantalla-inicio.mp4',
      assetPath: 'assets/background-tutorial-1.png',
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(children: [Spacer(flex: 6), _TutorialIntroCard()]),
      ),
    );
  }
}

class _TutorialIntroCard extends StatelessWidget {
  const _TutorialIntroCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        border: Border.all(color: AppColors.cardBorder),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
        ),
      ),
      child: Container(
        padding: AppSpacing.tutorialCardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/icon-crystal-ball-tutorial-1.png', width: 70, height: 70, fit: BoxFit.contain),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 17, height: 1.2),
                      children: const [
                        TextSpan(text: 'Descubre quién dice '),
                        TextSpan(
                          text: 'la verdad...',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        TextSpan(text: '\nY quién no.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(height: 1, color: AppColors.divider),
            const SizedBox(height: 18),
            Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14, height: 1.35),
                children: const [
                  TextSpan(text: 'La '),
                  TextSpan(
                    text: 'Profecía',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        ' es un juego de preguntas y retos extremos que pone a prueba a tus amigos o a tu pareja.\n\n',
                  ),
                  TextSpan(text: 'Si llegan al final sin remordimientos... ganan.\n\n'),
                  TextSpan(text: 'Si no... '),
                  TextSpan(
                    text: 'la profecía tenía razón.',
                    style: TextStyle(color: AppColors.primary),
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
