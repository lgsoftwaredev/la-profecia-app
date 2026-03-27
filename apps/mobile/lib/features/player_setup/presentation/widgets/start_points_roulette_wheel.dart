import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/game_setup_models.dart';

class StartPointsRouletteWheel extends StatefulWidget {
  const StartPointsRouletteWheel({
    required this.selectedTheme,
    required this.onThemeChanged,
    required this.onSpinCompleted,
    super.key,
  });

  final GameStyleTheme selectedTheme;
  final ValueChanged<GameStyleTheme> onThemeChanged;
  final ValueChanged<GameStyleTheme> onSpinCompleted;

  @override
  State<StartPointsRouletteWheel> createState() => _StartPointsRouletteWheelState();
}

class _StartPointsRouletteWheelState extends State<StartPointsRouletteWheel> with SingleTickerProviderStateMixin {
  static const _ringSize = 306.0;
  static const _wheelSize = 440.0;
  static const _themes = [
    GameStyleTheme.cielo,
    GameStyleTheme.tierra,
    GameStyleTheme.infierno,
    GameStyleTheme.inframundo,
  ];

  static const _pointerAngle = math.pi / 2;
  static const _baseAngles = {
    GameStyleTheme.infierno: -math.pi / 4,
    GameStyleTheme.cielo: math.pi / 4,
    GameStyleTheme.tierra: 3 * math.pi / 4,
    GameStyleTheme.inframundo: -3 * math.pi / 4,
  };

  final _random = math.Random();
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
        ..addListener(() => setState(() {}))
        ..addStatusListener(_handleStatus);

  Animation<double>? _rotationAnimation;
  double _rotation = 0;
  GameStyleTheme _targetTheme = GameStyleTheme.tierra;
  var _shouldOpenNextPage = false;

  @override
  void initState() {
    super.initState();
    _rotation = _rotationForTheme(widget.selectedTheme, from: 0, extraTurns: 0);
  }

  @override
  void didUpdateWidget(covariant StartPointsRouletteWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTheme != widget.selectedTheme && !_controller.isAnimating) {
      _animateToTheme(widget.selectedTheme, extraTurns: 0, durationMs: 420);
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
      widget.onSpinCompleted(_targetTheme);
    }
  }

  double _normalizeAngle(double angle) {
    const fullTurn = math.pi * 2;
    final value = angle % fullTurn;
    return value < 0 ? value + fullTurn : value;
  }

  double _rotationForTheme(GameStyleTheme theme, {required double from, required int extraTurns}) {
    final target = _pointerAngle - (_baseAngles[theme] ?? 0);
    var delta = _normalizeAngle(target) - _normalizeAngle(from);
    if (delta < 0) {
      delta += math.pi * 2;
    }
    return from + delta + (extraTurns * math.pi * 2);
  }

  void _animateToTheme(GameStyleTheme theme, {required int extraTurns, required int durationMs}) {
    _targetTheme = theme;
    final end = _rotationForTheme(theme, from: _rotation, extraTurns: extraTurns);
    _rotationAnimation = Tween<double>(
      begin: _rotation,
      end: end,
    ).animate(CurvedAnimation(parent: _controller, curve: extraTurns > 0 ? Curves.easeOutCubic : Curves.easeOut));
    _controller.duration = Duration(milliseconds: durationMs);
    _controller.forward(from: 0);
  }

  void _spin() {
    if (_controller.isAnimating) {
      return;
    }
    _shouldOpenNextPage = true;
    final nextTheme = _themes[_random.nextInt(_themes.length)];
    _animateToTheme(nextTheme, extraTurns: 4 + _random.nextInt(3), durationMs: 2300 + _random.nextInt(400));
  }

  double get _displayRotation => _rotationAnimation?.value ?? _rotation;

  List<Widget> _buildSegmentMarkers() {
    const center = Offset(_wheelSize / 2, _wheelSize / 2);
    final children = <Widget>[];

    for (final theme in _themes) {
      final baseAngle = _baseAngles[theme] ?? 0;
      final config = _visualConfigFor(theme);

      final textCenter = _polarOffset(
        center: center,
        radius: config.textRadius,
        angle: baseAngle + config.textAngleOffset,
      );
      final iconCenter = _polarOffset(
        center: center,
        radius: config.iconRadius,
        angle: baseAngle + config.iconAngleOffset,
      );

      children.add(
        Positioned(
          left: textCenter.dx - (config.textWidth / 2),
          top: textCenter.dy - 13,
          child: SizedBox(
            width: config.textWidth,
            height: 26,
            child: Transform.rotate(
              angle: config.textRotation,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  theme.label,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: 0.24,
                  ),
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
            child: _WheelThemeIcon(theme: theme, size: config.iconSize),
          ),
        ),
      );
    }

    return children;
  }

  Offset _polarOffset({required Offset center, required double radius, required double angle}) {
    return Offset(center.dx + (radius * math.cos(angle)), center.dy + (radius * math.sin(angle)));
  }

  _SectorVisualConfig _visualConfigFor(GameStyleTheme theme) => switch (theme) {
    GameStyleTheme.inframundo => const _SectorVisualConfig(
      textRadius: 170,
      textAngleOffset: -0.2,
      textRotation: 2.10,
      textWidth: 122,
      iconRadius: 136,
      iconAngleOffset: 6.14,
      iconSize: 44,
      iconRotation: 2,
    ),
    GameStyleTheme.infierno => const _SectorVisualConfig(
      textRadius: 143,
      textAngleOffset: -0.67,
      textRotation: -2.58,
      textWidth: 125,
      iconRadius: 107,
      iconAngleOffset: -0.80,
      iconSize: 34,
      iconRotation: 3.6,
    ),
    GameStyleTheme.cielo => const _SectorVisualConfig(
      textRadius: 57,
      textAngleOffset: -0.66,
      textRotation: -1.02,
      textWidth: 92,
      iconRadius: 25,
      iconAngleOffset: -1.2,
      iconSize: 34,
      iconRotation: 5.3,
    ),
    GameStyleTheme.tierra => const _SectorVisualConfig(
      textRadius: 116,
      textAngleOffset: 0.28,
      textRotation: 0.56,
      textWidth: 94,
      iconRadius: 87,
      iconAngleOffset: 0.54,
      iconSize: 34,
      iconRotation: 1.3,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final color = widget.selectedTheme.accentColor;

    return SizedBox(
      width: 354,
      height: 354,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 332,
            height: 332,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.50), blurRadius: 50, spreadRadius: 1)],
            ),
          ),
          SizedBox(
            width: _ringSize,
            height: _ringSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF3B489A), width: 6),
              ),
            ),
          ),
          SizedBox(
            width: _ringSize,
            height: _ringSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF77FF69).withValues(alpha: 0.75), width: 0.9),
              ),
            ),
          ),
          Transform.rotate(
            angle: _displayRotation,
            child: SizedBox(
              width: _wheelSize,
              height: _wheelSize,
              child: Stack(
                children: [
                  Image.asset('assets/ruleta.png', width: _wheelSize, height: _wheelSize, fit: BoxFit.contain),
                  ..._buildSegmentMarkers(),
                ],
              ),
            ),
          ),
          _Start3dButton(onTap: _spin),
          Positioned(
            bottom: 10,
            child: Image.asset('assets/logo-icon-flecha-ruleta.png', width: 35, height: 28, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _WheelThemeIcon extends StatelessWidget {
  const _WheelThemeIcon({required this.theme, required this.size});

  final GameStyleTheme theme;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (theme == GameStyleTheme.inframundo) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            '😈',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: size * 0.68,
              color: const Color(0xFFC246FF),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    final asset = switch (theme) {
      GameStyleTheme.cielo => 'assets/cielo-icon-logo.png',
      GameStyleTheme.tierra => 'assets/tierra-icon-logo.png',
      GameStyleTheme.infierno => 'assets/infierno-icon-logo.png',
      GameStyleTheme.inframundo => 'assets/inframundo-icon-logo.png',
    };

    return Image.asset(asset, width: size, height: size, fit: BoxFit.contain);
  }
}

class _SectorVisualConfig {
  const _SectorVisualConfig({
    required this.textRadius,
    required this.textAngleOffset,
    required this.textRotation,
    required this.textWidth,
    required this.iconRadius,
    required this.iconAngleOffset,
    required this.iconSize,
    required this.iconRotation,
  });

  final double textRadius;
  final double textAngleOffset;
  final double textRotation;
  final double textWidth;
  final double iconRadius;
  final double iconAngleOffset;
  final double iconSize;
  final double iconRotation;
}

class _Start3dButton extends StatefulWidget {
  const _Start3dButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_Start3dButton> createState() => _Start3dButtonState();
}

class _Start3dButtonState extends State<_Start3dButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: SizedBox(
        width: 102,
        height: 102,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOut,
              top: _pressed ? 6 : 8,
              child: Container(
                width: 98,
                height: 93,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF551738),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 18, offset: const Offset(0, 8)),
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOut,
              top: _pressed ? 2 : 0,
              child: Container(
                width: 98,
                height: 98,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFEA4D8C), Color(0xFF9A1A4D)],
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.32), width: 1.5),
                  boxShadow: [BoxShadow(color: const Color(0xFFE8418A).withValues(alpha: 0.55), blurRadius: 22)],
                ),
                child: Center(
                  child: Text(
                    'Iniciar',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
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
