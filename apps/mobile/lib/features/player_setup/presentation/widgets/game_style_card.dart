import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'level_card_frame.dart';

enum GameStyleCardLayout { standard, lockedCompact }

class GameStyleCard extends StatelessWidget {
  const GameStyleCard({
    required this.label,
    required this.subtitle,
    required this.iconAsset,
    required this.accentColor,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
    this.layout = GameStyleCardLayout.standard,
    this.showPremiumCornerBadge = false,
    super.key,
  });

  final String label;
  final String subtitle;
  final String iconAsset;
  final Color accentColor;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;
  final GameStyleCardLayout layout;
  final bool showPremiumCornerBadge;

  @override
  Widget build(BuildContext context) {
    final frameBorderColor =
        layout == GameStyleCardLayout.lockedCompact && isLocked
        ? const Color(0xFF6B7280)
        : accentColor;
    final card = LevelCardFrame(
      borderColor: frameBorderColor,
      isSelected: isSelected,
      enabled: true,
      onTap: onTap,
      height: layout == GameStyleCardLayout.standard ? 65 : 62,
      borderRadius: 20,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: layout == GameStyleCardLayout.standard
          ? _StandardContent(
              label: label,
              subtitle: subtitle,
              iconAsset: iconAsset,
              isSelected: isSelected,
              isLocked: isLocked,
            )
          : _LockedCompactContent(
              label: label,
              iconAsset: iconAsset,
              isSelected: isSelected,
            ),
    );

    if (!showPremiumCornerBadge) {
      return card;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        Positioned(
          top: -8,
          right: -2,
          child: Transform.rotate(
            angle: 22 * math.pi / 180,
            child: Image.asset(
              'assets/premium-icon-logo.png',
              width: 22,
              height: 22,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

class _StandardContent extends StatelessWidget {
  const _StandardContent({
    required this.label,
    required this.subtitle,
    required this.iconAsset,
    required this.isSelected,
    required this.isLocked,
  });

  final String label;
  final String subtitle;
  final String iconAsset;
  final bool isSelected;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.36),
            borderRadius: BorderRadius.circular(14),
          ),
          child: _CardIcon(iconAsset: iconAsset, isSelected: isSelected),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.23,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        if (isLocked)
          SizedBox(
            width: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/premium-icon-logo.png',
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                  color: const Color(0xFFDE8D00),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Premium',
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Image.asset(
                  'assets/logo-icon-lock.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          )
        else
          if(isSelected)
            Image.asset(
              'assets/logo-icon-checked.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              color: Colors.white,
            )
          else
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 3.2,
                ),
              ),
            ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}

class _LockedCompactContent extends StatelessWidget {
  const _LockedCompactContent({
    required this.label,
    required this.iconAsset,
    required this.isSelected,
  });

  final String label;
  final String iconAsset;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.36),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _CardIcon(iconAsset: iconAsset, isSelected: isSelected),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 32 * 0.50,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Image.asset(
          'assets/logo-icon-lock.png',
          width: 24,
          height: 24,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}

class _CardIcon extends StatelessWidget {
  const _CardIcon({required this.iconAsset, required this.isSelected});

  final String iconAsset;
  final bool isSelected;

  static const _grayscaleMatrix = <double>[
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
  ];

  @override
  Widget build(BuildContext context) {
    final icon = Image.asset(iconAsset, fit: BoxFit.contain);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      child: isSelected
          ? icon
          : ColorFiltered(
              colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
              child: icon,
            ),
    );
  }
}
