import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reflecto/models/habit.dart';

/// Integration tests for Firestore operations with fake_cloud_firestore
///
/// Coverage for #120: Firebase Emulator Integration Tests
void main() {
  group('Firestore - Habit CRUD Operations', () {
    late FakeFirebaseFirestore firestore;
    const testUid = 'test-user-123';

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    test('can create habit document in Firestore', () async {
      final habit = Habit(
        id: 'habit-1',
        title: 'Daily Reading',
        category: '📘 LERNEN',
        color: '#0A84FF',
        frequency: 'daily',
        sortIndex: 0,
        streak: 0,
        completedDates: [],
        createdAt: DateTime(2025, 11, 18),
        updatedAt: DateTime(2025, 11, 18),
      );

      // Write to Firestore
      await firestore
          .collection('users')
          .doc(testUid)
          .collection('habits')
          .doc(habit.id)
          .set(habit.toMap());

      // Read back
      final doc = await firestore
          .collection('users')
          .doc(testUid)
          .collection('habits')
          .doc(habit.id)
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()?['title'], 'Daily Reading');
      expect(doc.data()?['sortIndex'], 0);
    });

    test('can update habit sortIndex', () async {
      // Create initial habit
      await firestore
          .collection('users')
          .doc(testUid)
          .collection('habits')
          .doc('habit-1')
          .set({
        'title': 'Test Habit',
        'category': '📘 LERNEN',
        'color': '#0A84FF',
        'frequency': 'daily',
        'sortIndex': 0,
        'streak': 0,
        'completedDates': [],
      });

      // Update sortIndex
      await firestore
          .collection('users')
          .doc(testUid)
          .collection('habits')
          .doc('habit-1')
          .update({'sortIndex': 10});

      // Verify update
      final doc = await firestore
          .collection('users')
          .doc(testUid)
          .collection('habits')
          .doc('habit-1')
          .get();

      expect(doc.data()?['sortIndex'], 10);
    });

    test('can batch update multiple habits sortIndex', () async {
      // Create 3 habits
      final batch = firestore.batch();
      for (int i = 0; i < 3; i++) {
        final ref = firestore
            .collection('users')
            .doc(testUid)
            .collection('habits')
            .doc('habit-$i');
        batch.set(ref, {
          'title': 'Habit $i',
          'category': '📘 LERNEN',
          'color': '#0A84FF',
          'frequency': 'daily',
          'sortIndex': i * 10,
          'streak': 0,
          'completedDates': [],
        });
      }
      await batch.commit();

      // Batch update sortIndex (reverse order)
      final updateBatch = firestore.batch();
      for (int i = 0; i < 3; i++) {
        final ref = firestore
            .collection('users')
            .doc(testUid)
            .collection('habits')
            .doc('habit-$i');
        updateBatch.update(ref, {'sortIndex': (2 - i) * 10});
      }
      await updateBatch.commit();

      // Verify
      final habit0 = await firestore
          .collection('users')
          .doc(testUid)
          .collection('habits')
          .doc('habit-0')
          .get();
      expect(habit0.data()?['sortIndex'], 20); // Was 0, now 20
    });

    test('can query habits for user', () async {
      // Create multiple habits
      for (int i = 0; i < 5; i++) {
        await firestore
            .collection('users')
            .doc(testUid)
            .collection('habits')
            .doc('habit-$i')
            .set({
          'title': 'Habit $i',
          'category': '📘 LERNEN',
          'color': '#0A84FF',
          'frequency': 'daily',
          'sortIndex': i * 10,
          'streak': 0,
          'completedDates': [],
        });
      }

      // Query all habits
      final snapshot = await firestore
          .collection('users')
          .doc(testUid)
          .collection('habits')
          .get();

      expect(snapshot.docs.length, 5);
      expect(snapshot.docs[0].data()['title'], 'Habit 0');
    });

    test('can delete habit', () async {
      // Create habit
      await firestore
          .collection('users')
          .doc(testUid)
          .collection('habits')
          .doc('habit-to-delete')
          .set({
        'title': 'Delete Me',
        'category': '📘 LERNEN',
        'color': '#0A84FF',
        'frequency': 'daily',
        'sortIndex': 0,
        'streak': 0,
        'completedDates': [],
      });

      // Verify exists
      var doc = await firestore
          .collection('users')
          .doc(testUid)
          .collection('habits')
          .doc('habit-to-delete')
          .get();
      expect(doc.exists, isTrue);

      // Delete
      await firestore
          .collection('users')
          .doc(testUid)
          .collection('habits')
          .doc('habit-to-delete')
          .delete();

      // Verify deleted
      doc = await firestore
          .collection('users')
          .doc(testUid)
          .collection('habits')
          .doc('habit-to-delete')
          .get();
      expect(doc.exists, isFalse);
    });

    test('habit toMap/fromMap preserves all fields', () async {
      final original = Habit(
        id: 'habit-full',
        title: 'Complete Habit',
        category: '🚴 SPORT',
        color: '#FF3B30',
        frequency: 'weekly_days',
        weekdays: [1, 3, 5],
        reminderTime: '07:30',
        sortIndex: 20,
        streak: 10,
        completedDates: ['2025-11-18', '2025-11-17'],
        createdAt: DateTime(2025, 11, 1),
        updatedAt: DateTime(2025, 11, 18),
      );

      // Write
      await firestore
          .collection('users')
          .doc(testUid)
          .collection('habits')
          .doc(original.id)
          .set(original.toMap());

      // Read
      final doc = await firestore
          .collection('users')
          .doc(testUid)
          .collection('habits')
          .doc(original.id)
          .get();

      final restored = Habit.fromMap(original.id, doc.data()!);

      expect(restored.title, original.title);
      expect(restored.category, original.category);
      expect(restored.frequency, original.frequency);
      expect(restored.weekdays, original.weekdays);
      expect(restored.reminderTime, original.reminderTime);
      expect(restored.sortIndex, original.sortIndex);
      expect(restored.streak, original.streak);
      expect(restored.completedDates, original.completedDates);
    });
  });

  group('Firestore - User Isolation', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    test('users can only access their own habits collection', () async {
      const user1 = 'user-1';
      const user2 = 'user-2';

      // User 1 creates habit
      await firestore
          .collection('users')
          .doc(user1)
          .collection('habits')
          .doc('habit-1')
          .set({'title': 'User 1 Habit'});

      // User 2 creates habit
      await firestore
          .collection('users')
          .doc(user2)
          .collection('habits')
          .doc('habit-2')
          .set({'title': 'User 2 Habit'});

      // User 1 can read own habits
      final user1Habits = await firestore
          .collection('users')
          .doc(user1)
          .collection('habits')
          .get();
      expect(user1Habits.docs.length, 1);
      expect(user1Habits.docs[0].data()['title'], 'User 1 Habit');

      // User 2 can read own habits
      final user2Habits = await firestore
          .collection('users')
          .doc(user2)
          .collection('habits')
          .get();
      expect(user2Habits.docs.length, 1);
      expect(user2Habits.docs[0].data()['title'], 'User 2 Habit');

      // Collections are isolated
      expect(user1Habits.docs[0].id, 'habit-1');
      expect(user2Habits.docs[0].id, 'habit-2');
    });
  });
}
