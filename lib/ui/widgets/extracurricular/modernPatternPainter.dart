import 'package:flutter/material.dart';

class ModernPatternPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  ModernPatternPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dotPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    final double spacing = 40;

    // Draw curved lines
    for (double i = -size.width / 2; i < size.width * 1.5; i += spacing) {
      final path = Path();
      path.moveTo(i, 0);
      path.quadraticBezierTo(
          i + spacing / 2, size.height / 2, i + spacing, size.height);
      canvas.drawPath(path, paint);
    }

    // Add decorative dots
    for (int i = 0; i < 12; i++) {
      final x = (size.width * 0.1) + (i * size.width * 0.08);
      final y = size.height * 0.2 + (i % 3) * size.height * 0.3;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
