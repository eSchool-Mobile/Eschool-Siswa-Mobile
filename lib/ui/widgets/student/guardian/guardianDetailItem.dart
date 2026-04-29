import 'package:flutter/material.dart';

class GuardianDetailItem extends StatelessWidget {
  final String title;
  final String value;
  final Color primaryColor;
  final Color textColor;
  final AnimationController animationController;
  final int index;

  const GuardianDetailItem({
    Key? key,
    required this.title,
    required this.value,
    required this.primaryColor,
    required this.textColor,
    required this.animationController,
    this.index = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final delay = index * 0.2;
        final animValue = (animationController.value - delay).clamp(0.0, 1.0);
        return Opacity(
          opacity: 0.9,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: primaryColor,
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 15.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
