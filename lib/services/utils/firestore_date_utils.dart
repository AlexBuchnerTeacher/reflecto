import 'package:flutter/material.dart' show DateTimeRange;

/// Kleine Sammlung von Datumshilfen für Firestore-IDs & Wochen-Range.
class FirestoreDateUtils {
  FirestoreDateUtils._();

  static String two(int n) => n.toString().padLeft(2, '0');

  static String formatDate(DateTime d) =>
      '${d.year}-${two(d.month)}-${two(d.day)}';

  static int isoWeekNumber(DateTime date) {
    final thursday = date.add(Duration(days: 3 - ((date.weekday + 6) % 7)));
    final firstThursday = DateTime(thursday.year, 1, 4);
    return 1 + ((thursday.difference(firstThursday).inDays) / 7).floor();
  }

  static DateTime mondayOfWeek(DateTime d) {
    return DateTime(
      d.year,
      d.month,
      d.day,
    ).subtract(Duration(days: (d.weekday + 6) % 7));
  }

  static String weekIdFrom(DateTime d) {
    final thursday = d.add(Duration(days: 3 - ((d.weekday + 6) % 7)));
    final isoYear = thursday.year;
    final week = isoWeekNumber(d);
    return '$isoYear-${two(week)}';
  }

  static DateTimeRange weekRangeFrom(DateTime d) {
    final monday = mondayOfWeek(d);
    final start = DateTime(monday.year, monday.month, monday.day, 0, 0, 0);
    final endBase = monday.add(const Duration(days: 6));
    final end = DateTime(
      endBase.year,
      endBase.month,
      endBase.day,
      23,
      59,
      59,
      999,
    );
    return DateTimeRange(start: start, end: end);
  }
}
