import 'package:flutter/material.dart';

const Color _primaryColor = Color(0xFFE53935);
const Color _lightColor = Color(0xFFFFEBEE);

/// A labeled info row with a leading icon pill, optional top divider,
/// and italic styling for notes. Used inside subject attendance cards.
class AttendanceInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isNote;
  final bool showDivider;

  const AttendanceInfoRow(
    this.icon,
    this.text, {
    Key? key,
    this.isNote = false,
    this.showDivider = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.withValues(alpha: 0.1),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _lightColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: _primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: isNote ? FontStyle.italic : FontStyle.normal,
                    color: isNote ? Colors.grey[600] : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
