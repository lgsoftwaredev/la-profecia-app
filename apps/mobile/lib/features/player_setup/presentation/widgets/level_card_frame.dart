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

class VerticalLevelCardFrame extends StatelessWidget {
  const VerticalLevelCardFrame({
    required this.child,
    required this.borderColor,
    required this.baseTopColor,
    required this.baseBottomColor,
    required this.bottomTintStrong,
    required this.bottomTintSoft,
    required this.topLineColor,
    required this.topShadowStrongAlpha,
    required this.topShadowSoftAlpha,
    required this.onTap,
    this.enabled = true,
    this.width = 101,
    this.borderRadius = 18,
    this.borderThickness = 1.1,
    this.contentPadding = const EdgeInsets.fromLTRB(10, 9, 10, 9),
    this.glowColor,
    super.key,
  });

  final Widget child;
  final Color borderColor;
  final Color baseTopColor;
  final Color baseBottomColor;
  final Color bottomTintStrong;
  final Color bottomTintSoft;
  final Color topLineColor;
  final double topShadowStrongAlpha;
  final double topShadowSoftAlpha;
  final VoidCallback onTap;
  final bool enabled;
  final double width;
  final double borderRadius;
  final double borderThickness;
  final EdgeInsetsGeometry contentPadding;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final outerBorderGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        borderColor.withValues(alpha: 0.92),
        borderColor.withValues(alpha: 0.38),
        borderColor.withValues(alpha: 0.04),
      ],
      stops: const [0.0, 0.55, .9],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: outerBorderGradient,
          ),
          child: Container(
            margin: EdgeInsets.all(borderThickness),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                borderRadius - borderThickness,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [baseTopColor, baseBottomColor],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        bottomTintStrong,
                        bottomTintSoft,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.52, 0.92],
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: topShadowStrongAlpha),
                        Colors.black.withValues(alpha: topShadowSoftAlpha),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.30, 0.76],
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
