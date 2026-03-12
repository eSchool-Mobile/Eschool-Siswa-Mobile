import 'package:collection/collection.dart';
import 'dart:io';

void main() async {
  final file = File('lints.txt');
  final lines = await file.readAsLines();

  final regex = RegExp(r'\s-\s(.*?)\s-\s');
  final counts = <String, int>{};

  for (final line in lines) {
    final match = regex.firstMatch(line);
    if (match != null) {
      final issue = match.group(1);
      if (issue != null) {
        counts[issue] = (counts[issue] ?? 0) + 1;
      }
    }
  }

  final sortedCounts = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  for (final entry in sortedCounts) {
    print('${entry.value}: ${entry.key}');
  }
}
