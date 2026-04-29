import 'package:flutter/material.dart';

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Drawing decorative pattern
    double spacing = size.width / 10;

    // Draw circles
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
          Offset(size.width - 20, size.height / 2 - 30 + (i * 15)),
          10 + (i * 10),
          paint);
    }

    // Draw diagonal lines
    for (int i = 0; i < 8; i++) {
      canvas.drawLine(
        Offset(0, spacing * i),
        Offset(spacing * i, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
