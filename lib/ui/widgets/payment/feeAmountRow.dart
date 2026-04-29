import 'package:flutter/material.dart';

/// A labelled amount row with leading icon pill.
/// Pass [showZero] = true to render a row even when [amount] is 0.
class FeeAmountRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final bool isMain;
  final bool showZero;
  final String Function(double) formatCurrency;

  const FeeAmountRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.formatCurrency,
    this.isMain = false,
    this.showZero = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (amount == 0 && !showZero) return const SizedBox.shrink();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isMain ? 13 : 12,
              fontWeight: isMain ? FontWeight.w600 : FontWeight.w500,
              color: color.withValues(alpha: 0.9),
            ),
          ),
        ),
        Text(
          amount > 0 ? formatCurrency(amount) : "~",
          style: TextStyle(
            fontSize: isMain ? 14 : 13,
            fontWeight: FontWeight.bold,
            color: amount > 0 ? color : Colors.grey.shade600,
            fontStyle: amount > 0 ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
