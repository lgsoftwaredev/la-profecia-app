import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'tutorial_shared.dart';

const _tutorialModeCardMinHeight = 360.0;
const _tutorialModeRowMinHeight = 46.0;

class TutorialSecondView extends StatelessWidget {
  const TutorialSecondView({super.key});

  @override
  Widget build(BuildContext context) {
    return TutorialBackground(
      assetPath: 'assets/background-tutorial-2.png',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardsHeight = (constraints.maxHeight * 0.5).clamp(360.0, 460.0);
          final cardWidth = constraints.maxWidth * 0.7;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Image.asset('assets/logo-+18.png', width: 170),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Nuestros',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: 26, fontWeight: FontWeight.w700),
                      children: const [
                        TextSpan(text: 'Modos de '),
                        TextSpan(
                          text: 'juego',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    height: cardsHeight.toDouble(),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      children: [
                        _ModeCard(
                          width: cardWidth,
                          borderColor: AppColors.primary,
                          pillColor: AppColors.primary,
                          pillText: '2 personas o parejas',
                          title: 'Modo Pareja',
                          imagePath: 'assets/couple-mode.png',
                          items: const [
                            _ModeFeatureItem(emoji: '🥵', label: 'Más íntimo'),
                            _ModeFeatureItem(emoji: '🔥', label: 'Más Picante'),
                            _ModeFeatureItem(emoji: '😇', label: 'Más Honesto'),
                          ],
                          footerText:
                              'Ideal si creen que se conocen...\nspoiler: no tanto.',
                        ),
                        SizedBox(width: AppSpacing.md),
                        _ModeCard(
                          width: cardWidth,
                          borderColor: AppColors.secondary,
                          pillColor: AppColors.secondary,
                          pillText: 'De 2 a 10 jugadores',
                          title: 'Modo Amigos',
                          imagePath: 'assets/friends-mode.png',
                          items: const [
                            _ModeFeatureItem(
                              iconPath: 'assets/couple-mode-icon-1.png',
                              label: 'Más presión',
                            ),
                            _ModeFeatureItem(
                              iconPath: 'assets/couple-mode-icon-2.png',
                              label: 'Más atrevido',
                            ),
                            _ModeFeatureItem(
                              iconPath: 'assets/couple-mode-icon-3.png',
                              label: 'Más intenso',
                            ),
                          ],
                          footerText:
                              'Perfecto para destapar secretos y\nmejorar la relación 😉',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 17,
                          height: 1.35,
                        ),
                        children: const [
                          TextSpan(
                            text:
                                'La experiencia cambia según con quién\njuegues. Trae al ',
                          ),
                          TextSpan(
                            text: 'extrovertido/a.',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: ' 😉'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.width,
    required this.borderColor,
    required this.pillColor,
    required this.pillText,
    required this.title,
    required this.imagePath,
    required this.items,
    required this.footerText,
  });

  final double width;
  final Color borderColor;
  final Color pillColor;
  final String pillText;
  final String title;
  final String imagePath;
  final List<_ModeFeatureItem> items;
  final String footerText;

  @override
  Widget build(BuildContext context) {
    final imageWidth = (width * 0.56).clamp(78.0, 110.0);
    const outerRadius = 24.0;
    const borderThickness = 1.3;
    final innerRadius = outerRadius - borderThickness;
    final cornerGlow = borderColor.withValues(alpha: 0.12);

    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: _tutorialModeCardMinHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(outerRadius),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            borderColor.withValues(alpha: 0.95),
            borderColor.withValues(alpha: 0.34),
            borderColor.withValues(alpha: 0.1),
            borderColor.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.22, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: cornerGlow,
            blurRadius: 56,
            spreadRadius: -18,
            offset: const Offset(34, -22),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(borderThickness),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(innerRadius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [Color(0xE61A1B21), Color(0xE6000000)],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(innerRadius),
            gradient: RadialGradient(
              center: const Alignment(0.9, -1.0),
              radius: 0.6,
              colors: [borderColor.withValues(alpha: 0.05), Colors.transparent],
              stops: const [0.0, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: pillColor,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                pillText,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontSize: 16, height: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontSize: 20.5,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: imageWidth,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Image.asset(
                          imagePath,
                          width: imageWidth * 0.84,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  primary: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        _ModeRow(
                          emoji: items[i].emoji,
                          iconPath: items[i].iconPath,
                          label: items[i].label,
                        ),
                        if (i != items.length - 1)
                          const SizedBox(height: AppSpacing.xs),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        footerText,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 15.5,
                          height: 1.3,
                        ),
                      ),
                    ],
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

class _ModeFeatureItem {
  const _ModeFeatureItem({this.emoji, this.iconPath, required this.label})
    : assert(emoji != null || iconPath != null);

  final String? emoji;
  final String? iconPath;
  final String label;
}

class _ModeRow extends StatelessWidget {
  const _ModeRow({this.emoji, this.iconPath, required this.label})
    : assert(emoji != null || iconPath != null);

  final String? emoji;
  final String? iconPath;
  final String label;

  @override
  Widget build(BuildContext context) {
    final leadingWidget = iconPath != null
        ? Image.asset(iconPath!, width: 30, height: 32, fit: BoxFit.contain)
        : Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2027),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(emoji!, style: const TextStyle(fontSize: 22)),
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      constraints: const BoxConstraints(minHeight: _tutorialModeRowMinHeight),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          leadingWidget,
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontSize: 18.5, height: 1.05),
          ),
        ],
      ),
    );
  }
}
