import 'package:flutter/material.dart';
import 'package:drift_game/core/theme.dart';
import 'package:drift_game/models/gate.dart';

class GatePainter extends CustomPainter {
  final List<Gate> gates;
  final GamePalette palette;

  GatePainter({
    required this.gates,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double gateWidth = 60.0;
    const double cornerRadius = 12.0;

    for (final gate in gates) {
      // Skip gates that are off screen
      if (gate.x + gateWidth < 0 || gate.x > size.width) continue;

      // 1. Draw TOP Wall
      final Rect topRect = Rect.fromLTWH(gate.x, 0.0, gateWidth, gate.gapY);
      final RRect topRRect = RRect.fromRectAndCorners(
        topRect,
        bottomLeft: const Radius.circular(cornerRadius),
        bottomRight: const Radius.circular(cornerRadius),
      );

      final Paint topPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            palette.gateGradient[0].withOpacity(0.9),
            palette.gateGradient[1].withOpacity(0.9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(topRect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(topRRect, topPaint);

      // Subtle highlight line on the edge of the top cap
      final Paint capHighlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      
      // Draw a line at the bottom of the top gate RRect
      final Path topCapPath = Path()
        ..moveTo(gate.x + cornerRadius, gate.gapY)
        ..lineTo(gate.x + gateWidth - cornerRadius, gate.gapY);
      canvas.drawPath(topCapPath, capHighlightPaint);

      // 2. Draw BOTTOM Wall
      final double bottomWallHeight = size.height - (gate.gapY + gate.gapHeight);
      final Rect bottomRect = Rect.fromLTWH(
        gate.x,
        gate.gapY + gate.gapHeight,
        gateWidth,
        bottomWallHeight,
      );
      final RRect bottomRRect = RRect.fromRectAndCorners(
        bottomRect,
        topLeft: const Radius.circular(cornerRadius),
        topRight: const Radius.circular(cornerRadius),
      );

      final Paint bottomPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            palette.gateGradient[1].withOpacity(0.9),
            palette.gateGradient[0].withOpacity(0.9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bottomRect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(bottomRRect, bottomPaint);

      // Draw a line at the top of the bottom gate RRect
      final Path bottomCapPath = Path()
        ..moveTo(gate.x + cornerRadius, gate.gapY + gate.gapHeight)
        ..lineTo(gate.x + gateWidth - cornerRadius, gate.gapY + gate.gapHeight);
      canvas.drawPath(bottomCapPath, capHighlightPaint);

      // Draw a subtle border around the entire gates for depth (inner shadow effect)
      final Paint borderPaint = Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawRRect(topRRect, borderPaint);
      canvas.drawRRect(bottomRRect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GatePainter oldDelegate) {
    return oldDelegate.gates != gates || oldDelegate.palette.tier != palette.tier;
  }
}
