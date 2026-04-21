import 'package:flutter/material.dart';

class App3dPillButton extends StatefulWidget {
  const App3dPillButton({
    required this.label,
    required this.color,
    this.textStyle,
    this.leading,
    this.leadingIcon,
    this.leadingIconColor,
    this.leadingIconSize = 20,
    this.leadingIconGap = 8,
    this.gradientColors,
    this.gradientBegin = Alignment.topCenter,
    this.gradientEnd = Alignment.bottomCenter,
    this.height = 44,
    this.depth = 3.5,
    this.borderRadius = 999,
    this.isLoading = false,
    this.onTap,
    super.key,
  }) : assert(
         gradientColors == null || gradientColors.length >= 2,
         'gradientColors must contain at least 2 colors',
       ),
       assert(
         leading == null || leadingIcon == null,
         'Use either leading or leadingIcon, not both',
       );

  final String label;
  final Color color;
  final TextStyle? textStyle;
  final Widget? leading;
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final double leadingIconSize;
  final double leadingIconGap;
  final List<Color>? gradientColors;
  final Alignment gradientBegin;
  final Alignment gradientEnd;
  final double height;
  final double depth;
  final double borderRadius;
  final bool isLoading;
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
    final isEnabled = widget.onTap != null && !widget.isLoading;
    if (!isEnabled && _isPressed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _setPressed(false);
        }
      });
    }
    final topOffset = _isPressed && isEnabled ? widget.depth : 0.0;
    final fallbackTopStart = _shiftLightness(widget.color, 0.08);
    final fallbackTopEnd = _shiftLightness(widget.color, -0.01);
    final gradientColors =
        widget.gradientColors ?? [fallbackTopStart, fallbackTopEnd];
    final baseColor = _shiftLightness(gradientColors.last, -0.12);
    final resolvedTextStyle =
        widget.textStyle ??
        Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1,
        );
    final spinnerColor = resolvedTextStyle?.color ?? const Color(0xFF4D586D);
    final resolvedLeading =
        widget.leading ??
        (widget.leadingIcon == null
            ? null
            : Icon(
                widget.leadingIcon,
                size: widget.leadingIconSize,
                color: widget.leadingIconColor ?? resolvedTextStyle?.color,
              ));

    return Opacity(
      opacity: isEnabled ? 1 : 0.75,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: isEnabled ? (_) => _setPressed(true) : null,
        onTapUp: isEnabled ? (_) => _setPressed(false) : null,
        onTapCancel: isEnabled ? () => _setPressed(false) : null,
        onTap: isEnabled ? widget.onTap : null,
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
                    borderRadius: BorderRadius.circular(widget.borderRadius),
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
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    gradient: LinearGradient(
                      begin: widget.gradientBegin,
                      end: widget.gradientEnd,
                      colors: gradientColors,
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
                    child: widget.isLoading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                spinnerColor,
                              ),
                            ),
                          )
                        : resolvedLeading == null
                        ? Text(widget.label, style: resolvedTextStyle)
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              resolvedLeading,
                              SizedBox(width: widget.leadingIconGap),
                              Text(widget.label, style: resolvedTextStyle),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
