import 'package:eschool/utils/system/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AssignmentFloatingActionButton extends StatefulWidget {
  final bool isUndo;
  final VoidCallback onTap;

  const AssignmentFloatingActionButton({
    Key? key,
    required this.isUndo,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AssignmentFloatingActionButton> createState() =>
      _AssignmentFloatingActionButtonState();
}

class _AssignmentFloatingActionButtonState
    extends State<AssignmentFloatingActionButton> {
  bool _isHoveringUpload = false;
  final Color primaryColor = const Color(0xFFD22F3C);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 25.0, bottom: 25.0),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHoveringUpload = true),
          onExit: (_) => setState(() => _isHoveringUpload = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 300),
              tween: Tween<double>(
                  begin: 1.0, end: _isHoveringUpload ? 1.1 : 1.0),
              builder: (context, double scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 60,
                height: 60,
                padding: EdgeInsets.all(widget.isUndo ? 14 : 13),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: _isHoveringUpload ? 15 : 10,
                      offset: const Offset(0, 4),
                      color: primaryColor.withValues(
                          alpha: _isHoveringUpload ? 0.5 : 0.4),
                    )
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      primaryColor.withValues(
                          alpha: _isHoveringUpload ? 0.9 : 0.8)
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isHoveringUpload)
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 1500),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        builder: (context, double value, child) {
                          return AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _isHoveringUpload ? 1.0 : 0.0,
                            child: Container(
                              width: 60 * (1 + value * 0.2),
                              height: 60 * (1 + value * 0.2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    primaryColor.withValues(
                                        alpha: 0.6 * (1 - value)),
                                    primaryColor.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    SvgPicture.asset(
                      Utils.getImagePath(widget.isUndo
                          ? "undo_assignment_submission.svg"
                          : "file_upload_icon.svg"),
                      colorFilter: const ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
