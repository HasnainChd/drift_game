import 'package:flutter/material.dart';
import 'package:drift_game/providers/game_controller.dart';

class ParticlePainter extends CustomPainter {
  final List<GameParticle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.progress >= 1.0) continue;

      // Opacity fades out as progress increases
      final double opacity = 1.0 - p.progress;
      // Size decays slightly as progress increases
      final double currentSize = p.size * (1.0 - p.progress * 0.5);

      final Paint paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Optional: Add a glow to larger particles
      if (p.size > 5.0) {
        final Paint glowPaint = Paint()
          ..color = p.color.withOpacity(opacity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(p.x, p.y), currentSize * 1.8, glowPaint);
      }

      canvas.drawCircle(Offset(p.x, p.y), currentSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.particles != particles;
  }
}
