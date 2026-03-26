import 'package:flutter/material.dart';

class App3dPillButton extends StatefulWidget {
  const App3dPillButton({
    required this.label,
    required this.color,
    this.textStyle,
    this.height = 44,
    this.depth = 3.5,
    this.onTap,
    super.key,
  });

  final String label;
  final Color color;
  final TextStyle? textStyle;
  final double height;
  final double depth;
  final VoidCallback? onTap;

  @override
  State<App3dPillButton> createState() => _App3dPillButtonState();
}

class _App3dPillButtonState extends State<App3dPillButton> {
  bool _isPressed = false;

  Color _shiftLightness(Color base, double delta) {
    final hsl = HSLColor.fromColor(base);
    final nextLightness = (hsl.lightness + delta).clamp(0.0, 1.0).toDouble();
    return hsl.withLightness(nextLightness).toColor();
  }

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
    const radius = 999.0;
    final topOffset = _isPressed ? widget.depth : 0.0;
    final topStart = _shiftLightness(widget.color, 0.08);
    final topEnd = _shiftLightness(widget.color, -0.01);
    final baseColor = _shiftLightness(widget.color, -0.12);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: SizedBox(
        width: double.infinity,
        height: widget.height + widget.depth,
        child: Stack(
          children: [
            Positioned(
              top: widget.depth,
              left: 0,
              right: 0,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 85),
              curve: Curves.easeOut,
              top: topOffset,
              left: 0,
              right: 0,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [topStart, topEnd],
                  ),
                  boxShadow: _isPressed
                      ? const []
                      : [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.20),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    widget.label,
                    style:
                        widget.textStyle ??
                        Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
