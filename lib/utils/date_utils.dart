import 'package:intl/intl.dart';

/// Returns an ISO-like date id (YYYY-MM-DD) in UTC based on the local date.
/// Uses only the calendar date components and ignores time.
String isoDateId(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)}';
}

/// Parse an ISO-like date id (YYYY-MM-DD) into a local DateTime (00:00).
DateTime parseIsoDateId(String id) {
  final parts = id.split('-');
  if (parts.length != 3) {
    throw FormatException('Invalid date id: $id');
  }
  final y = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  final d = int.parse(parts[2]);
  return DateTime(y, m, d);
}

/// German long date, e.g. "Freitag, 8. November 2025".
String formatGermanLongDate(DateTime date) {
  final f = DateFormat.yMMMMEEEEd('de_DE');
  return f.format(date);
}

/// Short weekday name (Mo, Di, Mi, ...).
String weekdayShort(DateTime date) {
  final f = DateFormat.E('de_DE');
  return f.format(date);
}
