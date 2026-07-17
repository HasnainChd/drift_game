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
    const double arrowDepth = gateWidth * 0.65;

    for (final gate in gates) {
      // Skip gates that are off screen
      if (gate.x + gateWidth < 0 || gate.x > size.width) continue;

      // 1. Draw TOP Wall (Arrow pointing DOWN into the gap)
      final Path topPath = Path()
        ..moveTo(gate.x + cornerRadius, 0.0)
        ..quadraticBezierTo(gate.x, 0.0, gate.x, cornerRadius)
        ..lineTo(gate.x, gate.gapY - arrowDepth)
        ..lineTo(gate.x + gateWidth / 2, gate.gapY)
        ..lineTo(gate.x + gateWidth, gate.gapY - arrowDepth)
        ..lineTo(gate.x + gateWidth, cornerRadius)
        ..quadraticBezierTo(gate.x + gateWidth, 0.0, gate.x + gateWidth - cornerRadius, 0.0)
        ..close();

      final Rect topRect = Rect.fromLTWH(gate.x, 0.0, gateWidth, gate.gapY);
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

      canvas.drawPath(topPath, topPaint);

      // Subtle highlight line on the edge of the top cap
      final Paint capHighlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      
      final Path topCapPath = Path()
        ..moveTo(gate.x, gate.gapY - arrowDepth)
        ..lineTo(gate.x + gateWidth / 2, gate.gapY)
        ..lineTo(gate.x + gateWidth, gate.gapY - arrowDepth);
      canvas.drawPath(topCapPath, capHighlightPaint);

      // 2. Draw BOTTOM Wall (Arrow pointing UP into the gap)
      final Path bottomPath = Path()
        ..moveTo(gate.x, gate.gapY + gate.gapHeight + arrowDepth)
        ..lineTo(gate.x + gateWidth / 2, gate.gapY + gate.gapHeight)
        ..lineTo(gate.x + gateWidth, gate.gapY + gate.gapHeight + arrowDepth)
        ..lineTo(gate.x + gateWidth, size.height - cornerRadius)
        ..quadraticBezierTo(gate.x + gateWidth, size.height, gate.x + gateWidth - cornerRadius, size.height)
        ..lineTo(gate.x + cornerRadius, size.height)
        ..quadraticBezierTo(gate.x, size.height, gate.x, size.height - cornerRadius)
        ..close();

      final double bottomWallHeight = size.height - (gate.gapY + gate.gapHeight);
      final Rect bottomRect = Rect.fromLTWH(
        gate.x,
        gate.gapY + gate.gapHeight,
        gateWidth,
        bottomWallHeight,
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

      canvas.drawPath(bottomPath, bottomPaint);

      final Path bottomCapPath = Path()
        ..moveTo(gate.x, gate.gapY + gate.gapHeight + arrowDepth)
        ..lineTo(gate.x + gateWidth / 2, gate.gapY + gate.gapHeight)
        ..lineTo(gate.x + gateWidth, gate.gapY + gate.gapHeight + arrowDepth);
      canvas.drawPath(bottomCapPath, capHighlightPaint);

      // Draw a subtle border around the entire gates for depth (inner shadow effect)
      final Paint borderPaint = Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawPath(topPath, borderPaint);
      canvas.drawPath(bottomPath, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GatePainter oldDelegate) {
    return oldDelegate.gates != gates || oldDelegate.palette.tier != palette.tier;
  }
}
