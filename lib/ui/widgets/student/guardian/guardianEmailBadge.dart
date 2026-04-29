import 'package:eschool/utils/system/utils.dart';
import 'package:flutter/material.dart';

class GuardianEmailBadge extends StatelessWidget {
  final String? email;
  final bool onDarkBg;

  const GuardianEmailBadge({
    Key? key,
    this.email,
    this.onDarkBg = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final txt = Utils.formatEmptyValue(email ?? '');
    final bg = onDarkBg
        ? Colors.white.withValues(alpha: .15)
        : Colors.grey.shade100;
    final border = onDarkBg
        ? Colors.white.withValues(alpha: .35)
        : Colors.grey.shade300;
    final iconCol = onDarkBg ? Colors.white : Colors.grey.shade600;
    final textCol = onDarkBg ? Colors.white : Colors.grey.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 14, color: iconCol),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              txt,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: textCol),
            ),
          ),
        ],
      ),
    );
  }
}
