import 'package:flutter_test/flutter_test.dart';
import 'package:reflecto/models/habit.dart';

void main() {
  group('Habit Model - sortIndex', () {
    test('habits can be created with sortIndex', () {
      final habit = Habit(
        id: 'test-1',
        title: 'Test Habit',
        category: 'LERNEN',
        color: '#0A84FF',
        frequency: 'daily',
        sortIndex: 10,
        streak: 0,
        completedDates: [],
        createdAt: DateTime(2025, 11, 18),
        updatedAt: DateTime(2025, 11, 18),
      );
      expect(habit.sortIndex, 10);
    });

    test('habits without sortIndex default to null', () {
      final habit = Habit(
        id: 'test-2',
        title: 'Test Habit',
        category: 'LERNEN',
        color: '#0A84FF',
        frequency: 'daily',
        streak: 0,
        completedDates: [],
        createdAt: DateTime(2025, 11, 18),
        updatedAt: DateTime(2025, 11, 18),
      );
      expect(habit.sortIndex, isNull);
    });
  });
}
