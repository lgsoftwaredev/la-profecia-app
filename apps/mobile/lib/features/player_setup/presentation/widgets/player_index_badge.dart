import 'package:flutter/material.dart';

import 'premium_glass_surface.dart';

class PlayerIndexBadge extends StatelessWidget {
  const PlayerIndexBadge({
    required this.index,
    required this.accentColor,
    super.key,
  });

  final int index;
  final Color accentColor;

  Color _shiftLightness(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    final nextLightness = (hsl.lightness + delta).clamp(0.0, 1.0).toDouble();
    return hsl.withLightness(nextLightness).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final start = _shiftLightness(accentColor, 0.08);
    final end = _shiftLightness(accentColor, -0.06);

    return PremiumGlassSurface(
      width: 58,
      height: 58,
      borderRadius: BorderRadius.circular(18),
      borderColor: Colors.white.withValues(alpha: 0.24),
      innerBorderColor: Colors.white.withValues(alpha: 0.10),
      topHighlightOpacity: 0.10,
      bottomShadeOpacity: 0.14,
      gradientColors: [start, end],
      outerShadows: [
        BoxShadow(
          color: accentColor.withValues(alpha: 0.24),
          blurRadius: 16,
          offset: const Offset(0, 5),
        ),
      ],
      child: Center(
        child: Text(
          '$index',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
