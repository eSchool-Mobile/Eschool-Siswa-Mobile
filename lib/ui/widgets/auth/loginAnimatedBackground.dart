import 'package:eschool/ui/widgets/auth/loginBackgroundPainter.dart';
import 'package:flutter/material.dart';

/// Animated background widget for the login screens.
/// Renders a gradient, a decorative pattern, and floating decorative circles.
class LoginAnimatedBackground extends StatelessWidget {
  final Animation<double> backgroundFadeAnimation;
  final Color primaryColor;
  final Color secondaryColor;

  const LoginAnimatedBackground({
    Key? key,
    required this.backgroundFadeAnimation,
    required this.primaryColor,
    required this.secondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: backgroundFadeAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                primaryColor.withValues(alpha: 0.9),
                primaryColor.withRed((primaryColor.r * 255.0 * 0.85).round()),
                secondaryColor.withValues(alpha: 0.9),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Animated diagonal pattern
              Opacity(
                opacity: backgroundFadeAnimation.value * 0.7,
                child: CustomPaint(
                  painter: ModernBackgroundPatternPainter(
                    color: Colors.white.withValues(alpha: 0.09),
                  ),
                  size: Size.infinite,
                ),
              ),

              // Top-right decorative circle
              Positioned(
                top: -80,
                right: -80,
                child: AnimatedBuilder(
                  animation: backgroundFadeAnimation,
                  builder: (context, _) {
                    return Transform.scale(
                      scale: backgroundFadeAnimation.value,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: secondaryColor.withValues(alpha: 0.3),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Mid-left decorative circle
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                left: -20,
                child: AnimatedBuilder(
                  animation: backgroundFadeAnimation,
                  builder: (context, _) {
                    return Transform.scale(
                      scale: backgroundFadeAnimation.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: secondaryColor.withValues(alpha: 0.3),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
