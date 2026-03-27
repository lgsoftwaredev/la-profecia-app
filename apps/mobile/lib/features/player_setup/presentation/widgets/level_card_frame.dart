import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class LevelCardFrame extends StatelessWidget {
  const LevelCardFrame({
    required this.child,
    required this.borderColor,
    required this.height,
    required this.borderRadius,
    required this.onTap,
    this.isSelected = false,
    this.enabled = true,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
    this.borderThickness = 1.35,
    super.key,
  });

  final Widget child;
  final Color borderColor;
  final double height;
  final double borderRadius;
  final VoidCallback onTap;
  final bool isSelected;
  final bool enabled;
  final EdgeInsetsGeometry contentPadding;
  final double borderThickness;

  @override
  Widget build(BuildContext context) {
    const borderStops = [0.0, 0.28, 0.62, 1.0];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                borderColor.withValues(alpha: isSelected ? 0.95 : 0.78),
                borderColor.withValues(alpha: isSelected ? 0.22 : 0.16),
                borderColor.withValues(alpha: 0.12),
                borderColor.withValues(alpha: 0.0),
              ],
              stops: borderStops,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.50),
                      blurRadius: 20,
                      spreadRadius: -1,
                    ),
                  ]
                : null,
          ),
          child: Container(
            margin: EdgeInsets.all(borderThickness),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                borderRadius - borderThickness,
              ),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xE61A1B21), Color(0xE6000000)],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      borderRadius - borderThickness,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: const Alignment(-1, 0),
                      colors: [
                        borderColor.withValues(alpha: isSelected ? 0.18 : 0.14),
                        borderColor.withValues(alpha: isSelected ? 0.06 : 0.04),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.52, 0.88],
                    ),
                  ),
                ),
                Padding(padding: contentPadding, child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
