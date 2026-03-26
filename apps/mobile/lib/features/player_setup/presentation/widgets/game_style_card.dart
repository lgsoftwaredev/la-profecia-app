import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class GameStyleCard extends StatelessWidget {
  const GameStyleCard({
    required this.label,
    required this.iconAsset,
    required this.accentColor,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
    this.useCleanInframundoIcon = false,
    super.key,
  });

  final String label;
  final String iconAsset;
  final Color accentColor;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;
  final bool useCleanInframundoIcon;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? accentColor : accentColor.withValues(alpha: 0.74);
    const outerRadius = 20.0;
    const borderThickness = 1.35;
    const borderStops = [0.0, 0.28, 0.62, 1.0];

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      height: 74,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(outerRadius),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            borderColor.withValues(alpha: 0.95),
            borderColor.withValues(alpha: 0.22),
            borderColor.withValues(alpha: 0.16),
            borderColor.withValues(alpha: 0.0),
          ],
          stops: borderStops,
        ),
        boxShadow: isSelected
            ? [BoxShadow(color: accentColor.withValues(alpha: 0.50), blurRadius: 20, spreadRadius: 2)]
            : null,
      ),
      child: Container(
        margin: const EdgeInsets.all(borderThickness),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(outerRadius - borderThickness),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xE61A1B21), Color(0xE6000000)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(outerRadius - borderThickness),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.36),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _CardIcon(iconAsset: iconAsset, useCleanInframundo: useCleanInframundoIcon),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.23,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (isLocked)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/premium-icon-logo.png',
                          width: 18,
                          height: 18,
                          fit: BoxFit.contain,
                          color: const Color(0xFFDE8D00),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Premium',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        Image.asset('assets/logo-icon-lock.png', width: 22, height: 22, fit: BoxFit.contain),
                      ],
                    )
                  else
                    Image.asset(
                      'assets/logo-icon-checked.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      color: Colors.white.withValues(alpha: isSelected ? 0.98 : 0.35),
                    ),
                  const SizedBox(width: AppSpacing.xs),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: card),
    );
  }
}

class _CardIcon extends StatelessWidget {
  const _CardIcon({required this.iconAsset, required this.useCleanInframundo});

  final String iconAsset;
  final bool useCleanInframundo;

  @override
  Widget build(BuildContext context) {
    final isInframundo = useCleanInframundo && iconAsset.contains('inframundo-icon-logo');

    if (isInframundo) {
      return Center(
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          child: Text(
            '😈',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 31,
              color: const Color(0xFFC246FF),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Image.asset(iconAsset, fit: BoxFit.contain),
    );
  }
}
