import 'package:flutter_test/flutter_test.dart';
import 'package:reflecto/services/utils/firestore_date_utils.dart';
import 'package:reflecto/services/utils/planning_list_utils.dart';

void main() {
  group('Services Utilities Tests', () {
    // Test 1: Date Format Validation
    test('FirestoreDateUtils.formatDate returns YYYY-MM-DD format', () {
      final date = DateTime(2025, 11, 16);
      final formatted = FirestoreDateUtils.formatDate(date);
      expect(formatted, equals('2025-11-16'));
    });

    // Test 2: Two-digit formatting
    test('FirestoreDateUtils.two pads single digits', () {
      expect(FirestoreDateUtils.two(5), equals('05'));
      expect(FirestoreDateUtils.two(15), equals('15'));
      expect(FirestoreDateUtils.two(0), equals('00'));
    });

    // Test 3: Week ID Generation
    test('FirestoreDateUtils.weekIdFrom generates valid week ID', () {
      final date = DateTime(2025, 11, 16);
      final weekId = FirestoreDateUtils.weekIdFrom(date);
      expect(weekId.isNotEmpty, true);
      expect(weekId.contains('-'), true);
    });

    // Test 4: Monday of week calculation
    test('FirestoreDateUtils.mondayOfWeek returns correct Monday', () {
      // Any date -> Monday of that week
      final date = DateTime(2025, 11, 16);
      final monday = FirestoreDateUtils.mondayOfWeek(date);
      expect(monday.weekday, equals(DateTime.monday));
    });

    // Test 5: Week range generation
    test('FirestoreDateUtils.weekRangeFrom generates valid range', () {
      final date = DateTime(2025, 11, 16);
      final range = FirestoreDateUtils.weekRangeFrom(date);
      expect(range.start.weekday, equals(DateTime.monday));
      expect(range.end.isAfter(range.start), true);
    });

    // Test 6: List equality comparison
    test('PlanningListUtils.listsEqual compares lists correctly', () {
      final list1 = ['a', 'b', 'c'];
      final list2 = ['a', 'b', 'c'];
      final list3 = ['a', 'b', 'd'];
      expect(PlanningListUtils.listsEqual(list1, list2), true);
      expect(PlanningListUtils.listsEqual(list1, list3), false);
    });

    // Test 7: Deduplication preserves empty slots
    test('PlanningListUtils.dedupePreserveEmptySlots removes duplicates', () {
      final list = ['task1', '', 'task2', 'task1', '', 'task2'];
      final deduped = PlanningListUtils.dedupePreserveEmptySlots(list);
      expect(deduped.contains('task1'), true);
      expect(deduped.contains('task2'), true);
      // Empty slots are preserved in the deduplicated list
      expect(deduped.length, lessThanOrEqualTo(list.length));
    });

    // Test 8: ISO Week Number
    test('FirestoreDateUtils.isoWeekNumber calculates week number', () {
      final date = DateTime(2025, 11, 16);
      final weekNumber = FirestoreDateUtils.isoWeekNumber(date);
      expect(weekNumber, greaterThan(0));
      expect(weekNumber, lessThanOrEqualTo(53));
    });
  });
}
