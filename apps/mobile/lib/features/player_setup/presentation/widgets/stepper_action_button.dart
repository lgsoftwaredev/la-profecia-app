import 'package:flutter/material.dart';

import 'premium_glass_surface.dart';

class StepperActionButton extends StatefulWidget {
  const StepperActionButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.size = const Size(66, 58),
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final Size size;

  @override
  State<StepperActionButton> createState() => _StepperActionButtonState();
}

class _StepperActionButtonState extends State<StepperActionButton> {
  var _isPressed = false;
  var _isHovered = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }
    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.enabled;
    final borderColor = Colors.white.withValues(
      alpha: _isHovered ? 0.44 : 0.35,
    );
    final innerBorderColor = Colors.white.withValues(
      alpha: _isPressed ? 0.10 : 0.18,
    );

    final gradientColors = _isPressed
        ? const [Color(0xFF1A2D4A), Color(0xFF15243A)]
        : const [Color(0xFF253F63), Color(0xFF182B47)];

    return Opacity(
      opacity: isInteractive ? 1 : 0.42,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        scale: _isPressed ? 0.98 : 1,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          offset: _isPressed ? const Offset(0, 0.02) : Offset.zero,
          child: MouseRegion(
            onEnter: (_) => setState(() {
              _isHovered = true;
            }),
            onExit: (_) => setState(() {
              _isHovered = false;
              _isPressed = false;
            }),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: isInteractive ? (_) => _setPressed(true) : null,
              onTapCancel: isInteractive ? () => _setPressed(false) : null,
              onTapUp: isInteractive ? (_) => _setPressed(false) : null,
              onTap: isInteractive ? widget.onTap : null,
              child: PremiumGlassSurface(
                width: widget.size.width,
                height: widget.size.height,
                borderRadius: BorderRadius.circular(23),
                borderColor: borderColor,
                innerBorderColor: innerBorderColor,
                topHighlightOpacity: _isPressed ? 0.11 : 0.18,
                bottomShadeOpacity: _isPressed ? 0.22 : 0.18,
                gradientColors: gradientColors,
                outerShadows: _isPressed
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.32),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: const Color(
                            0xFF4B8DDB,
                          ).withValues(alpha: 0.12),
                          blurRadius: 18,
                          spreadRadius: -6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                child: Center(
                  child: Icon(
                    widget.icon,
                    color: Colors.white.withValues(alpha: 0.96),
                    size: 36,
                    weight: 700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
