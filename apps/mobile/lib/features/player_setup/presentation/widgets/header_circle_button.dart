import 'package:flutter/material.dart';

import 'premium_glass_surface.dart';

class HeaderCircleButton extends StatelessWidget {
  const HeaderCircleButton({required this.child, this.onTap, super.key});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: PremiumGlassSurface(
          width: 60,
          height: 46,
          borderRadius: radius,
          gradientColors: const [Color(0x88353B51), Color(0x55313749)],
          borderColor: Colors.white.withValues(alpha: 0.34),
          innerBorderColor: Colors.white.withValues(alpha: 0.10),
          topHighlightOpacity: 0.22,
          bottomShadeOpacity: 0.20,
          child: Center(child: child),
        ),
      ),
    );
  }
}
