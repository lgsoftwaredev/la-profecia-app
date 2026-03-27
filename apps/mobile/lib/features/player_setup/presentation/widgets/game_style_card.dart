import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'level_card_frame.dart';

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
    return LevelCardFrame(
      borderColor: accentColor,
      isSelected: isSelected,
      enabled: true,
      onTap: onTap,
      height: 74,
      borderRadius: 20,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.36),
              borderRadius: BorderRadius.circular(14),
            ),
            child: _CardIcon(
              iconAsset: iconAsset,
              useCleanInframundo: useCleanInframundoIcon,
            ),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Image.asset(
                  'assets/logo-icon-lock.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
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
    );
  }
}

class _CardIcon extends StatelessWidget {
  const _CardIcon({required this.iconAsset, required this.useCleanInframundo});

  final String iconAsset;
  final bool useCleanInframundo;

  @override
  Widget build(BuildContext context) {
    final isInframundo =
        useCleanInframundo && iconAsset.contains('inframundo-icon-logo');

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
