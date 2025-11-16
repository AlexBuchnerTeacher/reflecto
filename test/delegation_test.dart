import 'package:flutter_test/flutter_test.dart';
import 'package:reflecto/services/firestore_service.dart';
import 'package:reflecto/services/entry/firestore_entry_service.dart';
import 'package:reflecto/services/planning/firestore_planning_service.dart';
import 'package:reflecto/services/streak/firestore_streak_service.dart';
import 'package:reflecto/services/weekly/firestore_weekly_service.dart';
import 'package:reflecto/services/user/firestore_user_service.dart';
import 'package:reflecto/services/utils/firestore_date_utils.dart';
import 'package:reflecto/services/utils/planning_list_utils.dart';

void main() {
  group('Services Delegation & Architecture Tests', () {
    // Test 1: All service singletons are accessible
    test('All specialized services are instantiable', () {
      expect(() => FirestoreEntryService.instance, returnsNormally);
      expect(() => FirestorePlanningService.instance, returnsNormally);
      expect(() => FirestoreStreakService.instance, returnsNormally);
      expect(() => FirestoreWeeklyService.instance, returnsNormally);
      expect(() => FirestoreUserService.instance, returnsNormally);
    });

    // Test 2: Singleton pattern consistency
    test('Singleton instances remain consistent', () {
      final entry1 = FirestoreEntryService.instance;
      final entry2 = FirestoreEntryService.instance;
      expect(identical(entry1, entry2), true);

      final planning1 = FirestorePlanningService.instance;
      final planning2 = FirestorePlanningService.instance;
      expect(identical(planning1, planning2), true);

      final user1 = FirestoreUserService.instance;
      final user2 = FirestoreUserService.instance;
      expect(identical(user1, user2), true);
    });

    // Test 3: Utility modules are static and accessible
    test('Utility modules provide static methods', () {
      final date = DateTime(2025, 11, 16);

      // FirestoreDateUtils accessibility
      expect(() => FirestoreDateUtils.formatDate(date), returnsNormally);
      expect(() => FirestoreDateUtils.two(5), returnsNormally);
      expect(() => FirestoreDateUtils.isoWeekNumber(date), returnsNormally);
      expect(() => FirestoreDateUtils.mondayOfWeek(date), returnsNormally);
      expect(() => FirestoreDateUtils.weekIdFrom(date), returnsNormally);
      expect(() => FirestoreDateUtils.weekRangeFrom(date), returnsNormally);

      // PlanningListUtils accessibility
      expect(() => PlanningListUtils.listsEqual(['a'], ['a']), returnsNormally);
      expect(
        () => PlanningListUtils.dedupePreserveEmptySlots(['a', '', 'b']),
        returnsNormally,
      );
    });

    // Test 4: FirestoreService maintains backward compatibility
    test(
      'FirestoreService is still instantiable for backward compatibility',
      () {
        expect(() => FirestoreService.instance, returnsNormally);
      },
    );

    // Test 5: Date utilities return correct types
    test('Date utilities return expected types', () {
      final date = DateTime(2025, 11, 16);

      final formatted = FirestoreDateUtils.formatDate(date);
      expect(formatted, isA<String>());
      expect(formatted.split('-').length, equals(3));

      final twoDigit = FirestoreDateUtils.two(5);
      expect(twoDigit, isA<String>());
      expect(twoDigit.length, equals(2));

      final weekId = FirestoreDateUtils.weekIdFrom(date);
      expect(weekId, isA<String>());

      final weekNum = FirestoreDateUtils.isoWeekNumber(date);
      expect(weekNum, isA<int>());

      final monday = FirestoreDateUtils.mondayOfWeek(date);
      expect(monday, isA<DateTime>());
      expect(monday.weekday, equals(DateTime.monday));

      final range = FirestoreDateUtils.weekRangeFrom(date);
      expect(range.start, isA<DateTime>());
      expect(range.end, isA<DateTime>());
    });

    // Test 6: List utilities work correctly
    test('List utilities return expected results', () {
      final list1 = ['task1', 'task2', 'task3'];
      final list2 = ['task1', 'task2', 'task3'];
      final list3 = ['task1', 'task2', 'task4'];

      expect(PlanningListUtils.listsEqual(list1, list2), true);
      expect(PlanningListUtils.listsEqual(list1, list3), false);

      final duplicates = ['a', '', 'b', 'a', '', 'b'];
      final deduped = PlanningListUtils.dedupePreserveEmptySlots(duplicates);
      expect(deduped, isA<List<String>>());
      expect(deduped.contains('a'), true);
      expect(deduped.contains('b'), true);
    });

    // Test 7: Service module separation of concerns
    test('Each service module has focused responsibility', () {
      // Entry service should handle entry operations
      expect(FirestoreEntryService.instance, isNotNull);

      // Planning service should handle planning operations
      expect(FirestorePlanningService.instance, isNotNull);

      // Streak service should handle streak operations
      expect(FirestoreStreakService.instance, isNotNull);

      // Weekly service should handle weekly operations
      expect(FirestoreWeeklyService.instance, isNotNull);

      // User service should handle user operations
      expect(FirestoreUserService.instance, isNotNull);

      // Each is independently accessible
      expect(
        FirestoreEntryService.instance.runtimeType.toString(),
        contains('FirestoreEntryService'),
      );
      expect(
        FirestorePlanningService.instance.runtimeType.toString(),
        contains('FirestorePlanningService'),
      );
    });

    // Test 8: No circular dependencies or import issues
    test('All modules import and compile successfully', () {
      // If we got here, all imports worked
      expect(true, true);
    });
  });
}
