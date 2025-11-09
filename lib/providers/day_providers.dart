import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the currently selected calendar date (time ignored).
class DayState extends StateNotifier<DateTime> {
  DayState() : super(DateUtils.dateOnly(DateTime.now()));

  void set(DateTime date) => state = DateUtils.dateOnly(date);
  void today() => state = DateUtils.dateOnly(DateTime.now());
  void next() => state = state.add(const Duration(days: 1));
  void prev() => state = state.subtract(const Duration(days: 1));
}

final dayProvider = StateNotifierProvider<DayState, DateTime>((ref) {
  return DayState();
});
