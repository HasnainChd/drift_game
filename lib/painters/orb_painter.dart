import 'package:flutter/material.dart';
import 'package:drift_game/core/constants.dart';
import 'package:drift_game/core/theme.dart';

class OrbPainter extends CustomPainter {
  final double orbY;
  final double orbVelocity;
  final List<Offset> trail;
  final double radius;
  final GamePalette palette;
  final Color orbColor;
  final Color orbGlow;

  OrbPainter({
    required this.orbY,
    required this.orbVelocity,
    required this.trail,
    required this.radius,
    required this.palette,
    required this.orbColor,
    required this.orbGlow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double orbX = size.width * GameConstants.orbStartXPercent;

    // 1. Draw motion trail (un-rotated world space)
    if (trail.isNotEmpty) {
      for (int i = 0; i < trail.length; i++) {
        final double progress = (i + 1) / trail.length;
        final double trailRadius = radius * (0.3 + 0.7 * progress);
        final Color trailColor = orbColor.withOpacity(0.15 * progress);

        final Paint trailPaint = Paint()
          ..color = trailColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(trail[i], trailRadius, trailPaint);
      }
    }

    // Save state, translate to orb center, rotate, and draw orb
    canvas.save();
    canvas.translate(orbX, orbY);

    final double rotationAngle =
        (orbVelocity / GameConstants.terminalVelocity).clamp(-1.0, 1.0) * 0.4;
    canvas.rotate(rotationAngle);

    // 2. Draw soft outer glow
    final Paint glowPaint = Paint()
      ..color = orbGlow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius * 1.5, glowPaint);

    // 3. Draw inner orb with radial gradient
    final Rect orbRect = Rect.fromCircle(center: Offset.zero, radius: radius);
    final Paint orbPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          orbColor,
        ],
        stops: const [0.0, 1.0],
      ).createShader(orbRect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, radius, orbPaint);

    // 4. Add a tiny high-gloss reflection highlight
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(-radius * 0.3, -radius * 0.3),
      radius * 0.2,
      highlightPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant OrbPainter oldDelegate) {
    return oldDelegate.orbY != orbY ||
        oldDelegate.orbVelocity != orbVelocity ||
        oldDelegate.trail.length != trail.length ||
        oldDelegate.palette.tier != palette.tier ||
        oldDelegate.orbColor != orbColor ||
        oldDelegate.orbGlow != orbGlow;
  }
}
