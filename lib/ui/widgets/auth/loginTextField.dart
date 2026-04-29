import 'package:flutter/material.dart';

/// A styled text field for the login screens.
/// Supports animated slide-in, focus-aware border/shadow coloring,
/// leading icon, and an optional suffix widget (e.g. password toggle).
class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool obscureText;
  final IconData icon;
  final Animation<Offset> slideAnimation;
  final Widget? suffixWidget;
  final bool isFocused;
  final FocusNode focusNode;
  final Color primaryColor;

  const LoginTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.obscureText,
    required this.icon,
    required this.slideAnimation,
    required this.isFocused,
    required this.focusNode,
    required this.primaryColor,
    this.suffixWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color darkTextColor = Color(0xFF303030);

    return SlideTransition(
      position: slideAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
          border: Border.all(
            color: isFocused ? primaryColor : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Text(
                labelText,
                style: TextStyle(
                  color: isFocused ? primaryColor : Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50,
                  child: Center(
                    child: Icon(
                      icon,
                      color: isFocused ? primaryColor : Colors.grey.shade500,
                      size: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    obscureText: obscureText,
                    style: const TextStyle(
                      color: darkTextColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                      isDense: true,
                    ),
                  ),
                ),
                if (suffixWidget != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: suffixWidget,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
