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

  // A fixed set of stars to avoid regenerating on each frame
  static final List<BackgroundStar> _stars = List.generate(40, (index) {
    // Deterministic random properties
    final double x = (index * 137.5) % 1.0;
    final double y = (index * 72.3) % 1.0;
    final double size = 1.0 + (index % 3) * 0.8;
    final double speed = 10.0 + (index % 4) * 8.0; // px/s scrolling speed
    final double opacity = 0.05 + (index % 3) * 0.06;
    return BackgroundStar(x, y, size, speed, opacity);
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

    // 2. Draw Parallax Starfield (Scrolling slowly leftward)
    for (final star in _stars) {
      double starX = (star.xPercent * size.width - elapsedTime * star.speed) % size.width;
      if (starX < 0) starX += size.width;
      final double starY = star.yPercent * size.height;

      final Paint starPaint = Paint()
        ..color = Colors.white.withOpacity(star.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(starX, starY), star.size, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return oldDelegate.colorStart != colorStart ||
        oldDelegate.colorEnd != colorEnd ||
        oldDelegate.elapsedTime != elapsedTime;
  }
}

class BackgroundStar {
  final double xPercent;
  final double yPercent;
  final double size;
  final double speed;
  final double opacity;

  const BackgroundStar(
    this.xPercent,
    this.yPercent,
    this.size,
    this.speed,
    this.opacity,
  );
}
