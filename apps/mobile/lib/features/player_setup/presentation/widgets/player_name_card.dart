import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'player_index_badge.dart';
import 'premium_glass_surface.dart';

class PlayerNameCard extends StatelessWidget {
  const PlayerNameCard({
    required this.index,
    required this.controller,
    required this.badgeColor,
    required this.accentTint,
    required this.onChanged,
    this.showError = false,
    super.key,
  });

  final int index;
  final TextEditingController controller;
  final Color badgeColor;
  final Color accentTint;
  final ValueChanged<String> onChanged;
  final bool showError;

  Color _tinted(Color color, double amount) {
    return Color.lerp(const Color(0xFF1B2A43), color, amount)!;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = showError
        ? const Color(0xFFFF7BA0).withValues(alpha: 0.86)
        : Colors.white.withValues(alpha: 0.38);

    return PremiumGlassSurface(
      height: 82,
      borderRadius: BorderRadius.circular(26),
      borderColor: borderColor,
      innerBorderColor: Colors.white.withValues(alpha: 0.08),
      topHighlightOpacity: 0.12,
      bottomShadeOpacity: 0.20,
      gradientColors: [
        _tinted(accentTint, 0.13).withValues(alpha: 0.84),
        _tinted(accentTint, 0.07).withValues(alpha: 0.76),
      ],
      outerShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.30),
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
        BoxShadow(
          color: accentTint.withValues(alpha: 0.14),
          blurRadius: 18,
          spreadRadius: -9,
          offset: const Offset(0, 1),
        ),
      ],
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          PlayerIndexBadge(index: index, accentColor: badgeColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: controller,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              onChanged: onChanged,
              maxLines: 1,
              textInputAction: TextInputAction.next,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.96),
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Jugador $index',
                hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
        ],
      ),
    );
  }
}
