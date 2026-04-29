import 'dart:math';
import 'package:flutter/material.dart';

/// Paints diagonal dashed lines and subtle circles as a decorative
/// background pattern on the login screens.
class ModernBackgroundPatternPainter extends CustomPainter {
  final Color color;

  ModernBackgroundPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const double spacing = 40;
    const double dashLength = 5;
    const double dashSpace = 5;

    // Draw diagonal dashed lines
    for (double i = -size.height; i <= size.width + size.height; i += spacing) {
      double x = i;
      double y = 0;

      while (x < size.width && y < size.height) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x + dashLength, y + dashLength),
          paint,
        );

        x += dashLength + dashSpace;
        y += dashLength + dashSpace;
      }
    }

    // Draw subtle circles
    for (int i = 0; i < 10; i++) {
      final double x = (i * spacing * 1.5) % size.width;
      final double y = (i * spacing * 2) % size.height;
      final double radius = 25 + (i % 3) * 15;

      final circlePaint = Paint()
        ..color = color.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;

      canvas.drawCircle(Offset(x, y), radius, circlePaint);
    }
  }

  @override
  bool shouldRepaint(ModernBackgroundPatternPainter oldDelegate) => false;
}

/// Paints animated floating particles on the login background.
/// Currently unused in the UI but available for re-enabling.
class EnhancedFloatingParticlesPainter extends CustomPainter {
  final double animation;
  final Color particleColor;
  final int particleCount = 30;

  EnhancedFloatingParticlesPainter({
    required this.animation,
    required this.particleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particleCount; i++) {
      final seed = i * 10;
      final randomX = Random(seed);
      final randomY = Random(seed + 5);
      final randomSize = Random(seed + 10);

      final x = randomX.nextDouble() * size.width;
      final baseSpeed = randomY.nextDouble() * 0.6 + 0.2;
      final y =
          (randomY.nextDouble() * size.height + animation * 100 * baseSpeed) %
              size.height;

      final radius = randomSize.nextDouble() * 3 + 1;
      final opacity = randomSize.nextDouble() * 0.5 + 0.3;

      final paint = Paint()
        ..color = particleColor.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), radius, paint);

      // Add glow effect to some particles
      if (i % 3 == 0) {
        final glowPaint = Paint()
          ..color = particleColor.withValues(alpha: opacity * 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        canvas.drawCircle(Offset(x, y), radius * 2, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(EnhancedFloatingParticlesPainter oldDelegate) => true;
}
