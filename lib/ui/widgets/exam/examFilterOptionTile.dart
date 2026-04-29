import 'package:flutter/material.dart';

/// A single selectable filter chip tile used inside the exam filter bottom sheet.
/// Displays a leading icon and a label. The icon is determined by [filterValue].
class ExamFilterOptionTile extends StatelessWidget {
  final String title;
  final String filterValue;
  final bool isSelected;
  final VoidCallback onTap;
  final bool smallerFont;

  const ExamFilterOptionTile({
    Key? key,
    required this.title,
    required this.filterValue,
    required this.isSelected,
    required this.onTap,
    this.smallerFont = false,
  }) : super(key: key);

  Icon _getFilterIcon(BuildContext context) {
    final Color color =
        isSelected ? Colors.white : Theme.of(context).colorScheme.primary;
    switch (filterValue) {
      case 'ongoing':
        return Icon(Icons.play_circle_outline_rounded, color: color, size: 20);
      case 'completed':
        return Icon(Icons.check_circle_outline_rounded, color: color, size: 20);
      case 'upcoming':
        return Icon(Icons.upcoming_rounded, color: color, size: 20);
      case 'process':
        return Icon(Icons.hourglass_bottom, color: color, size: 20);
      case 'not_Yet':
        return Icon(Icons.cancel, color: color, size: 20);
      case 'all':
      default:
        return Icon(Icons.all_inclusive_rounded, color: color, size: 20);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fontSize = smallerFont
        ? (title.trim().split(" ").length > 1 ? 11 : 13)
        : (title.trim().split(" ").length > 1 ? 12 : 14);

    return Container(
      margin: const EdgeInsets.only(left: 5),
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color:
            isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
        border: Border.all(
          color: isSelected
              ? Colors.red
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _getFilterIcon(context),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
