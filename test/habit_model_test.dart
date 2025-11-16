import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reflecto/models/habit.dart';

void main() {
  group('Habit Model', () {
    test('fromMap creates Habit correctly', () {
      final map = {
        'title': 'Test Habit',
        'category': 'Gesundheit',
        'color': '#FF5252',
        'frequency': 'daily',
        'reminderTime': '19:00',
        'streak': 5,
        'completedDates': ['2025-11-01', '2025-11-02'],
        'createdAt': Timestamp.fromDate(DateTime(2025, 11, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2025, 11, 2)),
      };

      final habit = Habit.fromMap('test-id', map);

      expect(habit.id, 'test-id');
      expect(habit.title, 'Test Habit');
      expect(habit.category, 'Gesundheit');
      expect(habit.color, '#FF5252');
      expect(habit.frequency, 'daily');
      expect(habit.reminderTime, '19:00');
      expect(habit.streak, 5);
      expect(habit.completedDates.length, 2);
      expect(habit.completedDates, contains('2025-11-01'));
    });

    test('fromMap handles missing optional fields', () {
      final map = {
        'title': 'Minimal Habit',
        'category': 'Sport',
        'color': '#5B50FF',
        'frequency': 'weekly',
        'streak': 0,
        'completedDates': <String>[],
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      final habit = Habit.fromMap('habit-id', map);

      expect(habit.title, 'Minimal Habit');
      expect(habit.reminderTime, isNull);
      expect(habit.streak, 0);
      expect(habit.completedDates, isEmpty);
    });

    test('toMap serializes Habit correctly', () {
      final habit = Habit(
        id: 'test-id',
        title: 'Serialize Test',
        category: 'Lernen',
        color: '#4CAF50',
        frequency: 'daily',
        reminderTime: '08:00',
        streak: 3,
        completedDates: ['2025-11-15'],
        createdAt: DateTime(2025, 11, 15),
        updatedAt: DateTime(2025, 11, 15),
      );

      final map = habit.toMap();

      expect(map['title'], 'Serialize Test');
      expect(map['category'], 'Lernen');
      expect(map['color'], '#4CAF50');
      expect(map['frequency'], 'daily');
      expect(map['reminderTime'], '08:00');
      expect(map['streak'], 3);
      expect(map['completedDates'], ['2025-11-15']);
      expect(map['createdAt'], isA<Timestamp>());
      expect(map['updatedAt'], FieldValue.serverTimestamp());
    });

    test('copyWith creates modified copy', () {
      final original = Habit(
        id: 'id-1',
        title: 'Original',
        category: 'Gesundheit',
        color: '#FF5252',
        frequency: 'daily',
        streak: 2,
        completedDates: [],
        createdAt: DateTime(2025, 11, 1),
        updatedAt: DateTime(2025, 11, 1),
      );

      final modified = original.copyWith(title: 'Modified', streak: 5);

      expect(modified.id, original.id);
      expect(modified.title, 'Modified');
      expect(modified.streak, 5);
      expect(modified.category, original.category);
      expect(modified.color, original.color);
    });

    test('equality based on id', () {
      final habit1 = Habit(
        id: 'same-id',
        title: 'Habit 1',
        category: 'Sport',
        color: '#5B50FF',
        frequency: 'daily',
        streak: 0,
        completedDates: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final habit2 = Habit(
        id: 'same-id',
        title: 'Habit 2',
        category: 'Gesundheit',
        color: '#FF5252',
        frequency: 'weekly',
        streak: 5,
        completedDates: ['2025-11-01'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(habit1, equals(habit2));
      expect(habit1.hashCode, equals(habit2.hashCode));
    });
  });
}
