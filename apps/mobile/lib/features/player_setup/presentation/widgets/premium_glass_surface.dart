import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PremiumGlassSurface extends StatelessWidget {
  const PremiumGlassSurface({
    required this.child,
    required this.borderRadius,
    required this.gradientColors,
    required this.borderColor,
    this.width,
    this.height,
    this.padding = EdgeInsets.zero,
    this.outerShadows = const [],
    this.topHighlightOpacity = 0.14,
    this.bottomShadeOpacity = 0.20,
    this.topHighlightColor = Colors.white,
    this.bottomShadeColor = Colors.black,
    this.topLineHighlightColor,
    this.innerBorderColor,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final List<Color> gradientColors;
  final Color borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final List<BoxShadow> outerShadows;
  final double topHighlightOpacity;
  final double bottomShadeOpacity;
  final Color topHighlightColor;
  final Color bottomShadeColor;
  final Color? topLineHighlightColor;
  final Color? innerBorderColor;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: gradientBegin,
          end: gradientEnd,
          colors: gradientColors,
        ),
        boxShadow: outerShadows,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    topHighlightColor.withValues(alpha: topHighlightOpacity),
                    Colors.transparent,
                    bottomShadeColor.withValues(alpha: bottomShadeOpacity),
                  ],
                  stops: const [0, 0.96, 1],
                ),
              ),
            ),
            Positioned(
              top: 1,
              left: 16,
              right: 16,
              child: Container(
                height: 1.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      (topLineHighlightColor ?? topHighlightColor).withValues(
                        alpha: topHighlightOpacity + 0.11,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            if (innerBorderColor != null)
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(0.8),
                  decoration: BoxDecoration(
                    borderRadius: borderRadius.subtract(
                      const BorderRadius.all(Radius.circular(1)),
                    ),
                    border: Border.all(color: innerBorderColor!),
                  ),
                ),
              ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _PremiumBorderPainter(
                    borderRadius: borderRadius,
                    borderColor: borderColor,
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

class _PremiumBorderPainter extends CustomPainter {
  const _PremiumBorderPainter({
    required this.borderRadius,
    required this.borderColor,
  });

  final BorderRadius borderRadius;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final strokeRect = (Offset.zero & size).deflate(0.8);
    final rrect = borderRadius.toRRect(strokeRect);

    final baseStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.05
      ..color = borderColor.withValues(alpha: 0.00);

    final topLeftArcRect = Rect.fromCenter(
      center: Offset(rrect.left + rrect.tlRadiusX, rrect.top + rrect.tlRadiusY),
      width: rrect.tlRadiusX * 2,
      height: rrect.tlRadiusY * 2,
    );
    final bottomRightArcRect = Rect.fromCenter(
      center: Offset(
        rrect.right - rrect.brRadiusX,
        rrect.bottom - rrect.brRadiusY,
      ),
      width: rrect.brRadiusX * 2,
      height: rrect.brRadiusY * 2,
    );

    final cornerCoreStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .26
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = borderColor.withValues(alpha: 0.72);

    final cornerFeatherStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.9)
      ..color = borderColor.withValues(alpha: 0.22);

    final extension = math.min(size.shortestSide * 4.94, 320.0);
    final topMax =
        (rrect.right - rrect.trRadiusX) - (rrect.left + rrect.tlRadiusX) - 1;
    final leftMax =
        (rrect.bottom - rrect.blRadiusY) - (rrect.top + rrect.tlRadiusY) - 1;
    final rightMax =
        (rrect.bottom - rrect.brRadiusY) - (rrect.top + rrect.trRadiusY) - 1;
    final bottomMax =
        (rrect.right - rrect.brRadiusX) - (rrect.left + rrect.blRadiusX) - 1;

    final topExtension = math.max(0.0, math.min(extension, topMax));
    final leftExtension = math.max(0.0, math.min(extension, leftMax));
    final rightExtension = math.max(0.0, math.min(extension, rightMax));
    final bottomExtension = math.max(0.0, math.min(extension, bottomMax));

    final topCornerPoint = Offset(rrect.left + rrect.tlRadiusX, rrect.top);
    final leftCornerPoint = Offset(rrect.left, rrect.top + rrect.tlRadiusY);
    final topExtensionEnd = Offset(
      topCornerPoint.dx + topExtension,
      topCornerPoint.dy,
    );
    final leftExtensionEnd = Offset(
      leftCornerPoint.dx,
      leftCornerPoint.dy + leftExtension,
    );

    final bottomCornerPoint = Offset(
      rrect.right - rrect.brRadiusX,
      rrect.bottom,
    );
    final rightCornerPoint = Offset(
      rrect.right,
      rrect.bottom - rrect.brRadiusY,
    );
    final bottomExtensionEnd = Offset(
      bottomCornerPoint.dx - bottomExtension,
      bottomCornerPoint.dy,
    );
    final rightExtensionEnd = Offset(
      rightCornerPoint.dx,
      rightCornerPoint.dy - rightExtension,
    );

    final topLeftArcPath = Path()
      ..moveTo(topCornerPoint.dx, topCornerPoint.dy)
      ..arcTo(topLeftArcRect, math.pi * 1.5, -math.pi / 2, false);

    final bottomRightArcPath = Path()
      ..moveTo(bottomCornerPoint.dx, bottomCornerPoint.dy)
      ..arcTo(bottomRightArcRect, math.pi / 2, -math.pi / 2, false);

    final topExtensionPath = Path()
      ..moveTo(topCornerPoint.dx, topCornerPoint.dy)
      ..lineTo(topExtensionEnd.dx, topExtensionEnd.dy);
    final leftExtensionPath = Path()
      ..moveTo(leftCornerPoint.dx, leftCornerPoint.dy)
      ..lineTo(leftExtensionEnd.dx, leftExtensionEnd.dy);
    final bottomExtensionPath = Path()
      ..moveTo(bottomCornerPoint.dx, bottomCornerPoint.dy)
      ..lineTo(bottomExtensionEnd.dx, bottomExtensionEnd.dy);
    final rightExtensionPath = Path()
      ..moveTo(rightCornerPoint.dx, rightCornerPoint.dy)
      ..lineTo(rightExtensionEnd.dx, rightExtensionEnd.dy);

    Paint fadedStroke(Paint base, Offset start, Offset end, double startAlpha) {
      return Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = base.strokeWidth
        ..strokeCap = base.strokeCap
        ..strokeJoin = base.strokeJoin
        ..maskFilter = base.maskFilter
        ..shader = ui.Gradient.linear(start, end, [
          borderColor.withValues(alpha: startAlpha),
          borderColor.withValues(alpha: 0),
        ]);
    }

    canvas.drawRRect(rrect, baseStroke);
    canvas.drawPath(topLeftArcPath, cornerFeatherStroke);
    canvas.drawPath(bottomRightArcPath, cornerFeatherStroke);
    canvas.drawPath(topLeftArcPath, cornerCoreStroke);
    canvas.drawPath(bottomRightArcPath, cornerCoreStroke);

    if (topExtension > 0) {
      canvas.drawPath(
        topExtensionPath,
        fadedStroke(cornerFeatherStroke, topCornerPoint, topExtensionEnd, 0.22),
      );
      canvas.drawPath(
        topExtensionPath,
        fadedStroke(cornerCoreStroke, topCornerPoint, topExtensionEnd, 0.72),
      );
    }
    if (leftExtension > 0) {
      canvas.drawPath(
        leftExtensionPath,
        fadedStroke(
          cornerFeatherStroke,
          leftCornerPoint,
          leftExtensionEnd,
          0.22,
        ),
      );
      canvas.drawPath(
        leftExtensionPath,
        fadedStroke(cornerCoreStroke, leftCornerPoint, leftExtensionEnd, 0.72),
      );
    }
    if (bottomExtension > 0) {
      canvas.drawPath(
        bottomExtensionPath,
        fadedStroke(
          cornerFeatherStroke,
          bottomCornerPoint,
          bottomExtensionEnd,
          0.22,
        ),
      );
      canvas.drawPath(
        bottomExtensionPath,
        fadedStroke(
          cornerCoreStroke,
          bottomCornerPoint,
          bottomExtensionEnd,
          0.72,
        ),
      );
    }
    if (rightExtension > 0) {
      canvas.drawPath(
        rightExtensionPath,
        fadedStroke(
          cornerFeatherStroke,
          rightCornerPoint,
          rightExtensionEnd,
          0.22,
        ),
      );
      canvas.drawPath(
        rightExtensionPath,
        fadedStroke(
          cornerCoreStroke,
          rightCornerPoint,
          rightExtensionEnd,
          0.72,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderColor != borderColor;
  }
}
