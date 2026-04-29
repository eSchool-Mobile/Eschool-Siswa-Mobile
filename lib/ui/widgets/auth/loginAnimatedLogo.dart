import 'package:flutter/material.dart';

/// Animated circular logo widget for the login screens.
/// Scales in on entry and gently pulses to draw user attention.
class LoginAnimatedLogo extends StatelessWidget {
  final Animation<double> logoScaleAnimation;
  final Animation<double> pulseAnimation;
  final AnimationController logoController;
  final AnimationController pulseController;
  final Color primaryColor;
  final Color bgColor;
  final IconData icon;

  const LoginAnimatedLogo({
    Key? key,
    required this.logoScaleAnimation,
    required this.pulseAnimation,
    required this.logoController,
    required this.pulseController,
    required this.primaryColor,
    required this.bgColor,
    this.icon = Icons.school_rounded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([logoController, pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: logoScaleAnimation.value * pulseAnimation.value,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 3,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.9),
                      primaryColor,
                    ],
                    center: Alignment.topLeft,
                    radius: 1.0,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
