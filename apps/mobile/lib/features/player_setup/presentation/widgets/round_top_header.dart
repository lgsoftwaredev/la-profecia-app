import 'package:flutter/material.dart';

import 'header_circle_button.dart';
import 'premium_glass_surface.dart';

class RoundTopHeader extends StatelessWidget {
  const RoundTopHeader({
    required this.round,
    required this.isFriendsMode,
    this.onBackTap,
    this.onSettingsTap,
    this.showBackButton = true,
    this.showSettingsButton = true,
    super.key,
  });

  final int round;
  final bool isFriendsMode;
  final VoidCallback? onBackTap;
  final VoidCallback? onSettingsTap;
  final bool showBackButton;
  final bool showSettingsButton;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          if (showBackButton)
            HeaderCircleButton(
              onTap: onBackTap,
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
                size: 29,
              ),
            )
          else
            const SizedBox(width: 60, height: 46),
          const Spacer(),
          _RoundCapsule(round: round, isFriendsMode: isFriendsMode),
          const Spacer(),
          if (showSettingsButton)
            HeaderCircleButton(
              onTap: onSettingsTap,
              child: Image.asset(
                'assets/menu-logo-icon-settings.png',
                width: 21,
                height: 21,
                fit: BoxFit.contain,
              ),
            )
          else
            const SizedBox(width: 60, height: 46),
        ],
      ),
    );
  }
}

class _RoundCapsule extends StatelessWidget {
  const _RoundCapsule({required this.round, required this.isFriendsMode});

  final int round;
  final bool isFriendsMode;

  @override
  Widget build(BuildContext context) {
    final leftColor = isFriendsMode
        ? const Color(0xFF214C72)
        : const Color(0xFF6C2D5E);
    final midColor = isFriendsMode
        ? const Color(0xFF1D2E49)
        : const Color(0xFF4C2A5B);
    final rightColor = isFriendsMode
        ? const Color(0xFF262B3D)
        : const Color(0xFF2B233C);
    final capsuleBorder = isFriendsMode
        ? const Color(0xFF86C8FF)
        : const Color(0xFFF6A3CE);
    final badgeColor = isFriendsMode
        ? const Color(0xFF2B4866)
        : const Color(0xFF5A375E);

    return IntrinsicWidth(
      child: PremiumGlassSurface(
        height: 46,
        borderRadius: BorderRadius.circular(22),
        gradientBegin: Alignment.centerLeft,
        gradientEnd: Alignment.centerRight,
        gradientColors: [leftColor, midColor, rightColor],
        borderColor: capsuleBorder.withValues(alpha: 0.55),
        innerBorderColor: Colors.white.withValues(alpha: 0.10),
        topHighlightOpacity: 0.15,
        bottomShadeOpacity: 0.20,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeColor,
              ),
              alignment: Alignment.center,
              child: Text(
                '$round',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18 * 0.72,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Text(
              'Ronda',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 35 * 0.50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
