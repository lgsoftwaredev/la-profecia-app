import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'tutorial_shared.dart';

class TutorialFourthView extends StatefulWidget {
  const TutorialFourthView({super.key});

  @override
  State<TutorialFourthView> createState() => _TutorialFourthViewState();
}

class _TutorialFourthViewState extends State<TutorialFourthView> {
  late final PageController _pageController = PageController(
    viewportFraction: 0.72,
  );

  static const _cards = [
    _TutorialPointsCardData(
      iconAsset: 'assets/cielo-icon-logo.png',
      levelName: 'CIELO',
      levelColor: AppColors.secondary,
      pointsLabel: '+5',
      penaltyLabel: '-5',
      headline: 'Empieza suave',
      subline: 'Pero ya cuenta',
    ),
    _TutorialPointsCardData(
      iconAsset: 'assets/tierra-icon-logo.png',
      levelName: 'TIERRA',
      levelColor: Color(0xFF00D359),
      pointsLabel: '+10',
      penaltyLabel: '-10',
      headline: 'Aquí ya no hay pausa',
      subline: 'Empiezan las consecuencias',
    ),
    _TutorialPointsCardData(
      iconAsset: 'assets/infierno-icon-logo.png',
      levelName: 'INFIERNO',
      levelColor: Color(0xFFFF2B2B),
      pointsLabel: '+15',
      penaltyLabel: '-15',
      headline: 'Sube la intensidad',
      subline: 'Se pone muy picante',
    ),
    _TutorialPointsCardData(
      iconAsset: 'assets/inframundo-icon-logo.png',
      levelName: 'INFRAMUNDO',
      levelColor: Color(0xFFC246FF),
      pointsLabel: '+20',
      penaltyLabel: '-20',
      headline: 'Sin frenos',
      subline: 'O cumples o te consume',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TutorialBackground(
      assetPath: 'assets/background-tutorial-4.png',
      bottomReservedSpace: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth * 0.72;
          final cardsHeight = (constraints.maxHeight * 0.48).clamp(
            250.0,
            320.0,
          );
          final peopleWidth = constraints.maxWidth * 1.24;

          return Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    Image.asset('assets/logo-simple.png', width: 170),
                    const SizedBox(height: AppSpacing.lg),
                    Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                        children: const [
                          TextSpan(text: 'El sistema '),
                          TextSpan(
                            text: 'de puntos',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Cada decisión suma... o te destruye.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: cardsHeight,
                      child: AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, _) {
                          final currentPage = _pageController.hasClients
                              ? (_pageController.page ??
                                    _pageController.initialPage.toDouble())
                              : _pageController.initialPage.toDouble();

                          return PageView.builder(
                            controller: _pageController,
                            itemCount: _cards.length,
                            clipBehavior: Clip.none,
                            itemBuilder: (context, index) {
                              final distance = (currentPage - index).abs();
                              final focus = (1 - distance).clamp(0.0, 1.0);
                              const minScale = 0.88;
                              const maxScale = 1.1;
                              final scale =
                                  minScale + ((maxScale - minScale) * focus);
                              final yOffset = 6.0 - (20.0 * focus);
                              final card = _cards[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                ),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Transform.translate(
                                    offset: Offset(0, yOffset),
                                    child: Transform.scale(
                                      scale: scale,
                                      alignment: Alignment.topCenter,
                                      child: SizedBox(
                                        width: cardWidth,
                                        child: _TutorialPointsCard(
                                          iconAsset: card.iconAsset,
                                          levelName: card.levelName,
                                          levelColor: card.levelColor,
                                          pointsLabel: card.pointsLabel,
                                          penaltyLabel: card.penaltyLabel,
                                          headline: card.headline,
                                          subline: card.subline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        'assets/tutorial-4-people-bottom.png',
                        width: peopleWidth,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TutorialPointsCardData {
  const _TutorialPointsCardData({
    required this.iconAsset,
    required this.levelName,
    required this.levelColor,
    required this.pointsLabel,
    required this.penaltyLabel,
    required this.headline,
    required this.subline,
  });

  final String iconAsset;
  final String levelName;
  final Color levelColor;
  final String pointsLabel;
  final String penaltyLabel;
  final String headline;
  final String subline;
}

class _TutorialPointsCard extends StatelessWidget {
  const _TutorialPointsCard({
    required this.iconAsset,
    required this.levelName,
    required this.levelColor,
    required this.pointsLabel,
    required this.penaltyLabel,
    required this.headline,
    required this.subline,
  });

  final String iconAsset;
  final String levelName;
  final Color levelColor;
  final String pointsLabel;
  final String penaltyLabel;
  final String headline;
  final String subline;

  @override
  Widget build(BuildContext context) {
    const outerRadius = 20.0;
    const borderThickness = 1.35;
    const borderStops = [0.0, 0.28, 0.62, 1.0];

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(outerRadius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            levelColor.withValues(alpha: 0.95),
            levelColor.withValues(alpha: 0.22),
            levelColor.withValues(alpha: 0.16),
            levelColor.withValues(alpha: 0.0),
          ],
          stops: borderStops,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(borderThickness),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(outerRadius - borderThickness),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xE61A1B21), Color(0xE6000000)],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(outerRadius - borderThickness),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      levelColor.withValues(alpha: 0.18),
                      levelColor.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.52, 0.88],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  children: [
                    TutorialIconSquare(
                      iconAsset: iconAsset,
                      // backgroundColor: levelColor.withValues(alpha: 0.24),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Nivel',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 17 / 1.35,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      levelName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 44 / 2,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.54),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          Text.rich(
                            TextSpan(
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontSize: 20 / 1.05),
                              children: [
                                TextSpan(
                                  text: pointsLabel,
                                  style: TextStyle(
                                    color: levelColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 46 / 2,
                                  ),
                                ),
                                const TextSpan(text: ' puntos'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontSize: 15 / 1.35,
                                    color: Colors.white70,
                                  ),
                              children: [
                                TextSpan(
                                  text: '$penaltyLabel ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const TextSpan(text: 'Si no respondes'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      headline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 24 / 1.35,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 17 / 1.35,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
