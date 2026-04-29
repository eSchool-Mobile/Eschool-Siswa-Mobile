import 'package:eschool/ui/styles/colors.dart';
import 'package:flutter/material.dart';

/// Pill-shaped badge showing a student's attendance status for one period.
/// [type]: 1 = Hadir, 2 = Sakit, 3 = Izin, 4 = Alpa.
class AttendanceStatusBadge extends StatelessWidget {
  final int type;
  const AttendanceStatusBadge({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String status;
    final Color color;
    final IconData icon;

    switch (type) {
      case 1:
        status = 'Hadir';
        color = hadirColor;
        icon = Icons.check_circle;
        break;
      case 2:
        status = 'Sakit';
        color = sakitColor;
        icon = Icons.medical_services;
        break;
      case 3:
        status = 'Izin';
        color = izinColor;
        icon = Icons.event_busy;
        break;
      case 4:
        status = 'Alpa';
        color = alpaColor;
        icon = Icons.cancel;
        break;
      default:
        status = 'Tidak diketahui';
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
