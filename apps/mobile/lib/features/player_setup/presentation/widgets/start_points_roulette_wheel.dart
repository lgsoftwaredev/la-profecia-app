import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/game_setup_models.dart';
import '../../../match_play/domain/entities/match_level.dart';

class StartPointsRouletteWheel extends StatefulWidget {
  const StartPointsRouletteWheel({
    required this.selectedTheme,
    required this.availableThemes,
    required this.hasPremiumAccess,
    required this.isFriendsMode,
    required this.onSpinStarted,
    required this.onThemeChanged,
    required this.onSpinCompleted,
    required this.modeAccent,
    super.key,
  });

  final GameStyleTheme selectedTheme;
  final List<GameStyleTheme> availableThemes;
  final bool hasPremiumAccess;
  final bool isFriendsMode;
  final VoidCallback onSpinStarted;
  final ValueChanged<GameStyleTheme> onThemeChanged;
  final ValueChanged<GameStyleTheme> onSpinCompleted;
  final Color modeAccent;

  @override
  State<StartPointsRouletteWheel> createState() =>
      _StartPointsRouletteWheelState();
}

class _StartPointsRouletteWheelState extends State<StartPointsRouletteWheel>
    with SingleTickerProviderStateMixin {
  static const _wheelSize = 320.0;
  static const _themes = [
    GameStyleTheme.infierno,
    GameStyleTheme.cielo,
    GameStyleTheme.tierra,
    GameStyleTheme.inframundo,
  ];

  static const _pointerAngle = math.pi / 2;
  static const _baseAngles = {
    GameStyleTheme.infierno: -math.pi / 4.3,
    GameStyleTheme.cielo: math.pi / 3.3,
    GameStyleTheme.tierra: 3 * math.pi / 3.64,
    GameStyleTheme.inframundo: -3 * math.pi / 4.5,
  };

  final _random = math.Random();
  late final AnimationController _controller =
      AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 3400),
        )
        ..addListener(() => setState(() {}))
        ..addStatusListener(_handleStatus);

  Animation<double>? _rotationAnimation;
  double _rotation = 0;
  GameStyleTheme _targetTheme = GameStyleTheme.cielo;
  var _shouldOpenNextPage = false;

  @override
  void initState() {
    super.initState();
    _rotation = _rotationForTheme(widget.selectedTheme, from: 0, extraTurns: 0);
  }

  @override
  void didUpdateWidget(covariant StartPointsRouletteWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTheme != widget.selectedTheme &&
        !_controller.isAnimating) {
      _animateToTheme(widget.selectedTheme, extraTurns: 0, durationMs: 1000);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    _rotation = _rotationAnimation?.value ?? _rotation;
    widget.onThemeChanged(_targetTheme);
    if (_shouldOpenNextPage) {
      _shouldOpenNextPage = false;
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          widget.onSpinCompleted(_targetTheme);
        }
      });
    }
  }

  double _normalizeAngle(double angle) {
    const fullTurn = math.pi * 2;
    final value = angle % fullTurn;
    return value < 0 ? value + fullTurn : value;
  }

  double _rotationForTheme(
    GameStyleTheme theme, {
    required double from,
    required int extraTurns,
  }) {
    final target = _pointerAngle - (_baseAngles[theme] ?? 0);
    var delta = _normalizeAngle(target) - _normalizeAngle(from);
    if (delta < 0) {
      delta += math.pi * 2;
    }
    return from + delta + (extraTurns * math.pi * 2);
  }

  void _animateToTheme(
    GameStyleTheme theme, {
    required int extraTurns,
    required int durationMs,
  }) {
    _targetTheme = theme;
    final end = _rotationForTheme(
      theme,
      from: _rotation,
      extraTurns: extraTurns,
    );
    _rotationAnimation = Tween<double>(begin: _rotation, end: end).animate(
      CurvedAnimation(
        parent: _controller,
        curve: extraTurns > 0 ? Curves.easeOutCubic : Curves.easeOut,
      ),
    );
    _controller.duration = Duration(milliseconds: durationMs);
    _controller.forward(from: 0);
  }

  void _spin() {
    if (_controller.isAnimating) {
      return;
    }
    widget.onSpinStarted();
    _shouldOpenNextPage = true;
    final candidates = widget.availableThemes.isEmpty
        ? const [GameStyleTheme.cielo]
        : widget.availableThemes;
    final nextTheme = candidates[_random.nextInt(candidates.length)];
    _animateToTheme(
      nextTheme,
      extraTurns: 4 + _random.nextInt(3),
      durationMs: 4200 + _random.nextInt(360),
    );
  }

  double get _displayRotation => _rotationAnimation?.value ?? _rotation;

  bool _isThemePremiumLocked(GameStyleTheme theme) {
    return !widget.hasPremiumAccess && theme.toMatchLevel.isPremium;
  }

  List<Widget> _buildSegmentMarkers() {
    const center = Offset(_wheelSize / 2, _wheelSize / 2);
    final children = <Widget>[];

    for (final theme in _themes) {
      final baseAngle = _baseAngles[theme] ?? 0;
      final config = _visualConfigFor(theme);
      final isPremiumLocked = _isThemePremiumLocked(theme);
      final isEnabled = widget.availableThemes.contains(theme);
      final pointsText = theme.toMatchLevel.points > 0
          ? '+${theme.toMatchLevel.points} puntos'
          : '${theme.toMatchLevel.points} puntos';

      final textCenter = _polarOffset(
        center: center,
        radius: config.textRadius,
        angle: baseAngle + config.textAngleOffset,
      );
      final pointsCenter = _polarOffset(
        center: center,
        radius: config.pointsRadius,
        angle: baseAngle + config.pointsAngleOffset,
      );
      final iconCenter = _polarOffset(
        center: center,
        radius: config.iconRadius,
        angle: baseAngle + config.iconAngleOffset,
      );

      children.add(
        Positioned(
          left: textCenter.dx - (config.textWidth / 2),
          top: textCenter.dy - 14,
          child: SizedBox(
            width: config.textWidth,
            height: 28,
            child: Transform.rotate(
              angle: config.textRotation,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  theme.label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isPremiumLocked
                        ? Colors.white.withValues(alpha: 0.62)
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.5,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      children.add(
        Positioned(
          left: pointsCenter.dx - 38,
          top: pointsCenter.dy - 2,
          child: Transform.rotate(
            angle: config.textRotation,
            child: SizedBox(
              width: 76,
              child: Text(
                pointsText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isPremiumLocked
                      ? Colors.white.withValues(alpha: 0.44)
                      : const Color(0xCCFFFFFF),
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
      );

      children.add(
        Positioned(
          left: iconCenter.dx - (config.iconSize / 2),
          top: iconCenter.dy - (config.iconSize / 2),
          child: Transform.rotate(
            angle: config.iconRotation,
            alignment: Alignment.center,
            child: _WheelThemeIcon(
              theme: theme,
              size: config.iconSize,
              isPremiumLocked: isPremiumLocked,
              isEnabled: isEnabled,
            ),
          ),
        ),
      );
    }

    return children;
  }

  Offset _polarOffset({
    required Offset center,
    required double radius,
    required double angle,
  }) {
    return Offset(
      center.dx + (radius * math.cos(angle)),
      center.dy + (radius * math.sin(angle)),
    );
  }

  _SectorVisualConfig _visualConfigFor(GameStyleTheme theme) => switch (theme) {
    GameStyleTheme.inframundo => const _SectorVisualConfig(
      textRadius: 122,
      textAngleOffset: -0.24,
      textRotation: 2.40,
      textWidth: 118,
      pointsRadius: 108,
      pointsAngleOffset: -0.14,
      iconRadius: 83,
      iconAngleOffset: -0.25,
      iconSize: 30,
      iconRotation: 2.3,
    ),
    GameStyleTheme.infierno => const _SectorVisualConfig(
      textRadius: 122,
      textAngleOffset: -0.12,
      textRotation: -2.40,
      textWidth: 110,
      pointsRadius: 108,
      pointsAngleOffset: -0.12,
      iconRadius: 83,
      iconAngleOffset: -0.10,
      iconSize: 30,
      iconRotation: 3.8,
    ),
    GameStyleTheme.cielo => const _SectorVisualConfig(
      textRadius: 122,
      textAngleOffset: -0.19,
      textRotation: -0.82,
      textWidth: 94,
      pointsRadius: 100,
      pointsAngleOffset: -0.19,
      iconRadius: 84,
      iconAngleOffset: -0.20,
      iconSize: 30,
      iconRotation: 5.5,
    ),
    GameStyleTheme.tierra => const _SectorVisualConfig(
      textRadius: 121,
      textAngleOffset: -0.22,
      textRotation: 0.88,
      textWidth: 94,
      pointsRadius: 100,
      pointsAngleOffset: -0.17,
      iconRadius: 84,
      iconAngleOffset: -0.2,
      iconSize: 30,
      iconRotation: 1.5,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 352,
      height: 354,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 338,
            height: 338,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.modeAccent.withValues(alpha: 0.48),
                  blurRadius: 54,
                  spreadRadius: 0.4,
                ),
              ],
            ),
          ),
          Transform.rotate(
            angle: _displayRotation,
            child: SizedBox(
              width: _wheelSize,
              height: _wheelSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size.square(_wheelSize),
                    painter: _WheelSegmentsPainter(
                      selectedTheme: widget.selectedTheme,
                      availableThemes: widget.availableThemes,
                      hasPremiumAccess: widget.hasPremiumAccess,
                    ),
                  ),
                  ..._buildSegmentMarkers(),
                ],
              ),
            ),
          ),
          _CenterDiceButton(
            onTap: _spin,
            isFriendsMode: widget.isFriendsMode,
            modeAccent: widget.modeAccent,
          ),
          Positioned(
            bottom: 9,
            child: Image.asset(
              'assets/logo-icon-flecha-ruleta.png',
              width: 37,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelSegmentsPainter extends CustomPainter {
  const _WheelSegmentsPainter({
    required this.selectedTheme,
    required this.availableThemes,
    required this.hasPremiumAccess,
  });

  final GameStyleTheme selectedTheme;
  final List<GameStyleTheme> availableThemes;
  final bool hasPremiumAccess;

  _ThemeBorderStyle _borderStyleFor(GameStyleTheme theme) => switch (theme) {
    GameStyleTheme.infierno => const _ThemeBorderStyle(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      strokeWidth: 2.6,
      sideStrokeWidth: 2.0,
      leadingAlphaFactor: 0.34,
      sideAlphaFactor: 0.92,
      paintSides: true,
      stops: [0, 0.08, 1.0],
      selectedAlpha: 0.96,
      availableAlpha: 0.76,
      lockedAlpha: 0.58,
      inactiveAlpha: 0.42,
      midAlphaFactor: 0.44,
    ),
    GameStyleTheme.cielo => const _ThemeBorderStyle(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      strokeWidth: 2.6,
      sideStrokeWidth: 1.0,
      leadingAlphaFactor: 0.50,
      sideAlphaFactor: 0.90,
      paintSides: true,
      stops: [1.0, 0.60, 0.0],
      selectedAlpha: 0.94,
      availableAlpha: 0.74,
      lockedAlpha: 0.58,
      inactiveAlpha: 0.42,
      midAlphaFactor: 0.44,
    ),
    GameStyleTheme.tierra => const _ThemeBorderStyle(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      strokeWidth: 2.6,
      sideStrokeWidth: 2.0,
      leadingAlphaFactor: 0.50,
      sideAlphaFactor: 0.90,
      paintSides: true,
      stops: [1.0, 0.60, 0.0],
      selectedAlpha: 0.94,
      availableAlpha: 0.74,
      lockedAlpha: 0.58,
      inactiveAlpha: 0.42,
      midAlphaFactor: 0.44,
    ),
    GameStyleTheme.inframundo => const _ThemeBorderStyle(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      strokeWidth: 2.4,
      sideStrokeWidth: 1.8,
      leadingAlphaFactor: 0.08,
      sideAlphaFactor: 0.84,
      paintSides: true,
      stops: [0.0, 0.62, 1.0],
      selectedAlpha: 0.90,
      availableAlpha: 0.68,
      lockedAlpha: 0.52,
      inactiveAlpha: 0.38,
      midAlphaFactor: 0.44,
    ),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentOuterRadius = radius - 8;
    final segmentInnerRadius = radius * 0.40;
    const themes = [
      GameStyleTheme.infierno,
      GameStyleTheme.cielo,
      GameStyleTheme.tierra,
      GameStyleTheme.inframundo,
    ];
    const baseAngles = {
      GameStyleTheme.infierno: -math.pi / 4,
      GameStyleTheme.cielo: math.pi / 4,
      GameStyleTheme.tierra: 3 * math.pi / 4,
      GameStyleTheme.inframundo: -3 * math.pi / 4,
    };

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF2C3246)
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius - 3, ringPaint);

    final centerGapPaint = Paint()
      ..shader =
          RadialGradient(
            center: const Alignment(-0.08, -0.08),
            radius: 1,
            colors: const [Color(0xFF1A1E29), Color(0xFF11141D)],
          ).createShader(
            Rect.fromCircle(center: center, radius: segmentInnerRadius),
          );
    canvas.drawCircle(center, segmentInnerRadius, centerGapPaint);

    final centerGapBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = const Color(0xFF32394A).withValues(alpha: 0.78);
    canvas.drawCircle(center, segmentInnerRadius, centerGapBorder);

    for (final theme in themes) {
      final start = (baseAngles[theme] ?? 0) - (math.pi / 4);
      final isPremiumLocked = !hasPremiumAccess && theme.toMatchLevel.isPremium;
      final path = Path()
        ..arcTo(
          Rect.fromCircle(center: center, radius: segmentOuterRadius),
          start,
          math.pi / 2,
          true,
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: segmentInnerRadius),
          start + (math.pi / 2),
          -math.pi / 2,
          false,
        )
        ..close();

      final isSelected = theme == selectedTheme;
      final isAvailable = availableThemes.contains(theme);
      final selectedBaseColor = isPremiumLocked
          ? const Color(0xFF5F6269)
          : theme.accentColor;
      final fill = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.28, -0.24),
          radius: 1.02,
          colors: [
            isSelected || isAvailable
                ? selectedBaseColor.withValues(
                    alpha: isPremiumLocked ? 0.22 : 1,
                  )
                : isPremiumLocked
                ? const Color.fromARGB(255, 46, 46, 46)
                : const Color.fromARGB(255, 46, 46, 46),
            isPremiumLocked ? const Color(0xFF14161C) : const Color(0xFF0D0E13),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawPath(path, fill);

      // Add an internal soft shadow from right to left inside each segment.
      final shadowAngle = start;
      final segmentShadowAlpha = isPremiumLocked
          ? (isSelected || isAvailable ? 0.46 : 0.40)
          : (isSelected || isAvailable ? 0.94 : 0.90);
      final innerShadowRadius = segmentInnerRadius;
      final outerShadowRadius = segmentOuterRadius;
      final shadowStart = Offset(
        center.dx + (outerShadowRadius * math.cos(shadowAngle)),
        center.dy + (outerShadowRadius * math.sin(shadowAngle)),
      );
      final shadowEnd = Offset(
        center.dx + (innerShadowRadius * math.cos(shadowAngle)),
        center.dy + (innerShadowRadius * math.sin(shadowAngle)),
      );
      final shadow = Paint()
        ..color = const Color.fromARGB(
          255,
          20,
          20,
          20,
        ).withValues(alpha: segmentShadowAlpha)
        ..strokeWidth = 240
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 98);
      canvas.save();
      canvas.clipPath(path);
      canvas.drawLine(shadowStart, shadowEnd, shadow);
      canvas.restore();

      final borderBaseColor = isSelected || isAvailable
          ? selectedBaseColor
          : isPremiumLocked
          ? const Color(0xFF3A3D48)
          : isAvailable
          ? theme.accentColor
          : const Color(0xFF2D3242);
      final borderStyle = _borderStyleFor(theme);
      final maxAlpha = isPremiumLocked
          ? borderStyle.lockedAlpha
          : isSelected
          ? borderStyle.selectedAlpha
          : isAvailable
          ? borderStyle.availableAlpha
          : borderStyle.inactiveAlpha;
      final border = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderStyle.strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          begin: borderStyle.begin,
          end: borderStyle.end,
          colors: [
            borderBaseColor.withValues(
              alpha: maxAlpha * borderStyle.leadingAlphaFactor,
            ),
            borderBaseColor.withValues(
              alpha: maxAlpha * borderStyle.midAlphaFactor,
            ),
            borderBaseColor.withValues(alpha: maxAlpha),
          ],
          stops: borderStyle.stops,
        ).createShader(path.getBounds());
      final sideBorder = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderStyle.sideStrokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          begin: borderStyle.begin,
          end: borderStyle.end,
          colors: [
            borderBaseColor.withValues(
              alpha: maxAlpha * borderStyle.leadingAlphaFactor,
            ),
            borderBaseColor.withValues(
              alpha: maxAlpha * borderStyle.midAlphaFactor,
            ),
            borderBaseColor.withValues(
              alpha: maxAlpha * borderStyle.sideAlphaFactor,
            ),
          ],
          stops: borderStyle.stops,
        ).createShader(path.getBounds());
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: segmentOuterRadius),
        start,
        math.pi / 2,
        false,
        border,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: segmentInnerRadius),
        start,
        math.pi / 2,
        false,
        border,
      );
      final end = start + (math.pi / 2);
      final startOuter = Offset(
        center.dx + (segmentOuterRadius * math.cos(start)),
        center.dy + (segmentOuterRadius * math.sin(start)),
      );
      final startInner = Offset(
        center.dx + (segmentInnerRadius * math.cos(start)),
        center.dy + (segmentInnerRadius * math.sin(start)),
      );
      final endOuter = Offset(
        center.dx + (segmentOuterRadius * math.cos(end)),
        center.dy + (segmentOuterRadius * math.sin(end)),
      );
      final endInner = Offset(
        center.dx + (segmentInnerRadius * math.cos(end)),
        center.dy + (segmentInnerRadius * math.sin(end)),
      );
      if (borderStyle.paintSides) {
        canvas.drawLine(startOuter, startInner, sideBorder);
        canvas.drawLine(endOuter, endInner, sideBorder);
      }
    }

    final centerHaloRadius = segmentInnerRadius > 6
        ? segmentInnerRadius - 6
        : 0.0;
    final centerHalo = Paint()
      ..shader = RadialGradient(
        colors: [
          selectedTheme.accentColor.withValues(alpha: 0.56),
          selectedTheme.accentColor.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: centerHaloRadius));
    canvas.drawCircle(center, centerHaloRadius, centerHalo);
  }

  @override
  bool shouldRepaint(covariant _WheelSegmentsPainter oldDelegate) {
    return oldDelegate.selectedTheme != selectedTheme ||
        !listEquals(oldDelegate.availableThemes, availableThemes) ||
        oldDelegate.hasPremiumAccess != hasPremiumAccess;
  }
}

class _ThemeBorderStyle {
  const _ThemeBorderStyle({
    required this.begin,
    required this.end,
    required this.strokeWidth,
    required this.sideStrokeWidth,
    required this.leadingAlphaFactor,
    required this.sideAlphaFactor,
    required this.paintSides,
    required this.stops,
    required this.selectedAlpha,
    required this.availableAlpha,
    required this.lockedAlpha,
    required this.inactiveAlpha,
    required this.midAlphaFactor,
  });

  final Alignment begin;
  final Alignment end;
  final double strokeWidth;
  final double sideStrokeWidth;
  final double leadingAlphaFactor;
  final double sideAlphaFactor;
  final bool paintSides;
  final List<double> stops;
  final double selectedAlpha;
  final double availableAlpha;
  final double lockedAlpha;
  final double inactiveAlpha;
  final double midAlphaFactor;
}

class _CenterDiceButton extends StatefulWidget {
  const _CenterDiceButton({
    required this.onTap,
    required this.isFriendsMode,
    required this.modeAccent,
  });

  final VoidCallback onTap;
  final bool isFriendsMode;
  final Color modeAccent;

  @override
  State<_CenterDiceButton> createState() => _CenterDiceButtonState();
}

class _CenterDiceButtonState extends State<_CenterDiceButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final topColor = widget.modeAccent;
    final bottomColor = widget.isFriendsMode
        ? const Color(0xFF042240)
        : Color.lerp(widget.modeAccent, Colors.black, 0.72)!;
    final glowColor = widget.modeAccent;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.95 : 1,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [topColor, bottomColor],
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.72),
                blurRadius: 15,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo-icon-dice-ruleta.png',
                width: 55,
                height: 45,
                fit: BoxFit.contain,
              ),
              Text(
                'Aleatorio',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.94),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelThemeIcon extends StatelessWidget {
  const _WheelThemeIcon({
    required this.theme,
    required this.size,
    required this.isPremiumLocked,
    required this.isEnabled,
  });

  final GameStyleTheme theme;
  final double size;
  final bool isPremiumLocked;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final asset = switch (theme) {
      GameStyleTheme.cielo => 'assets/cielo-icon-logo.png',
      GameStyleTheme.tierra => 'assets/tierra-icon-logo.png',
      GameStyleTheme.infierno => 'assets/infierno-icon-logo.png',
      GameStyleTheme.inframundo => 'assets/inframundo-icon-logo.png',
    };
    final icon = Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
    final useLockedStyle = isPremiumLocked || !isEnabled;
    if (!useLockedStyle) {
      return icon;
    }
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
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
      ]),
      child: icon,
    );
  }
}

class _SectorVisualConfig {
  const _SectorVisualConfig({
    required this.textRadius,
    required this.textAngleOffset,
    required this.textRotation,
    required this.textWidth,
    required this.pointsRadius,
    required this.pointsAngleOffset,
    required this.iconRadius,
    required this.iconAngleOffset,
    required this.iconSize,
    required this.iconRotation,
  });

  final double textRadius;
  final double textAngleOffset;
  final double textRotation;
  final double textWidth;
  final double pointsRadius;
  final double pointsAngleOffset;
  final double iconRadius;
  final double iconAngleOffset;
  final double iconSize;
  final double iconRotation;
}
