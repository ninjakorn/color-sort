// lib/features/game/ui/tube_effects.dart

import 'package:flutter/material.dart';

/// Custom painter for glass shine effect
class GlassShinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw a subtle shine gradient
    final rect = Rect.fromLTWH(
      size.width * 0.2,
      0,
      size.width * 0.6,
      size.height,
    );
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final gradientPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, gradientPaint);
  }

  @override
  bool shouldRepaint(GlassShinePainter oldDelegate) => false;
}

/// Custom painter for liquid shine effect
class LiquidShinePainter extends CustomPainter {
  final Color baseColor;

  LiquidShinePainter({required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a curved highlight
    final highlightPath =
        Path()
          ..moveTo(size.width * 0.1, size.height * 0.1)
          ..quadraticBezierTo(
            size.width * 0.5,
            size.height * 0.2,
            size.width * 0.9,
            size.height * 0.1,
          )
          ..lineTo(size.width * 0.9, size.height * 0.3)
          ..quadraticBezierTo(
            size.width * 0.5,
            size.height * 0.4,
            size.width * 0.1,
            size.height * 0.3,
          )
          ..close();

    final Color lighterColor = Color.fromRGBO(
      (baseColor.red + 40).clamp(0, 255),
      (baseColor.green + 40).clamp(0, 255),
      (baseColor.blue + 40).clamp(0, 255),
      0.3,
    );

    final paint =
        Paint()
          ..color = lighterColor
          ..style = PaintingStyle.fill;

    canvas.drawPath(highlightPath, paint);
  }

  @override
  bool shouldRepaint(LiquidShinePainter oldDelegate) =>
      oldDelegate.baseColor != baseColor;
}
