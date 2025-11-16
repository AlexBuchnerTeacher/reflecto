import 'package:flutter_test/flutter_test.dart';
import 'package:reflecto/services/firestore_service.dart';

void main() {
  group('FirestoreService Delegation Tests', () {
    test('FirestoreService has test constructor with dependency injection', () {
      // This test verifies that the test constructor exists and can be called
      final service = FirestoreService.test();
      expect(service, isNotNull);
      expect(service, isA<FirestoreService>());
    });

    test('FirestoreService singleton pattern works', () {
      final instance1 = FirestoreService.instance;
      final instance2 = FirestoreService();
      expect(identical(instance1, instance2), isTrue);
    });

    test('FirestoreService test constructor creates separate instance', () {
      final singleton = FirestoreService.instance;
      final testInstance = FirestoreService.test();
      expect(identical(singleton, testInstance), isFalse);
    });

    test('FirestoreService has all delegation methods', () {
      final service = FirestoreService.instance;

      // Verify that all key methods are available
      expect(service.ensureEntry, isA<Function>());
      expect(service.updateField, isA<Function>());
      expect(service.getDailyEntry, isA<Function>());
      expect(service.fetchWeekEntries, isA<Function>());
      expect(service.saveUserData, isA<Function>());
      expect(service.getUser, isA<Function>());
      expect(service.movePlanningItemToNextDay, isA<Function>());
      expect(service.moveSpecificPlanningItem, isA<Function>());
      expect(service.dedupeAllPlanningForUser, isA<Function>());
      expect(service.saveWeeklyReflection, isA<Function>());
      expect(service.weeklyReflectionStream, isA<Function>());
      expect(service.markEveningCompletedAndUpdateStreak, isA<Function>());
    });
  });
}
