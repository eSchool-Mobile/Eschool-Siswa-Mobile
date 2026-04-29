import 'package:flutter/material.dart';
import 'package:eschool/ui/widgets/system/expandableText.dart';

/// Displays an accented reason block with an icon, title, source chip, and
/// expandable body text. Used for leave reason and reject-reason sections.
class LeaveReasonSection extends StatelessWidget {
  const LeaveReasonSection({
    super.key,
    required this.title,
    required this.text,
    required this.sourceLabel,
    required this.icon,
    required this.accent,
    this.margin,
  });

  final String title;
  final String text;
  final String sourceLabel;
  final IconData icon;
  final Color accent;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: margin ?? const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: accent.withValues(alpha: 0.3)),
                ),
                child: Text(
                  sourceLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ExpandableText(
            text: text,
            style: TextStyle(
              height: 1.35,
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.85),
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
