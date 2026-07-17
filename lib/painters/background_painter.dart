import 'dart:math';
import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  final Color colorStart;
  final Color colorEnd;
  final double elapsedTime;

  BackgroundPainter({
    required this.colorStart,
    required this.colorEnd,
    required this.elapsedTime,
  });

  static final Random _random = Random(42);
  static final List<Star> _stars = List.generate(80, (index) {
    return Star(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      baseRadius: _random.nextDouble() > 0.9 ? 2.0 + _random.nextDouble() * 0.5 : 0.5 + _random.nextDouble() * 1.0,
      twinkleSpeed: 1.0 + _random.nextDouble() * 3.0,
      twinklePhaseOffset: _random.nextDouble() * 2 * pi,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Vertical Gradient Background
    final Rect bgRect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [colorStart, colorEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bgRect);

    canvas.drawRect(bgRect, bgPaint);

    // 2. Draw Parallax Starfield (Scrolling slowly downward)
    // Scroll speed is roughly 10-15% of gate scroll. Let's say 25.0 px/s
    final double scrollSpeed = 25.0;

    for (final star in _stars) {
      final double opacity = 0.3 + 0.5 * (0.5 + 0.5 * sin(elapsedTime * star.twinkleSpeed + star.twinklePhaseOffset));
      
      double starY = (star.y * size.height + elapsedTime * scrollSpeed) % size.height;
      double starX = star.x * size.width;

      final Paint starPaint = Paint()
        ..color = Colors.white.withOpacity(opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(starX, starY), star.baseRadius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return oldDelegate.colorStart != colorStart ||
        oldDelegate.colorEnd != colorEnd ||
        oldDelegate.elapsedTime != elapsedTime;
  }
}

class Star {
  final double x; // 0.0-1.0, relative to screen width
  final double y; // 0.0-1.0, relative to screen height
  final double baseRadius;
  final double twinkleSpeed; // radians/sec
  final double twinklePhaseOffset; // radians

  const Star({
    required this.x,
    required this.y,
    required this.baseRadius,
    required this.twinkleSpeed,
    required this.twinklePhaseOffset,
  });
}
