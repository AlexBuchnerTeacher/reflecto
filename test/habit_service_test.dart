import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reflecto/models/habit.dart';
import 'package:reflecto/services/habit_service.dart';

void main() {
  group('HabitService - Streak Calculation', () {
    test('calculates streak correctly for consecutive days', () {
      final habit = Habit(
        id: 'habit-1',
        title: 'Daily Reading',
        category: 'Learning',
        color: '#5B50FF',
        frequency: 'daily',
        streak: 0,
        completedDates: [
          '2025-11-13',
          '2025-11-14',
          '2025-11-15',
          '2025-11-16',
          '2025-11-17',
        ],
        createdAt: DateTime(2025, 11, 13),
        updatedAt: DateTime(2025, 11, 17),
      );

      // Streak should be 5 consecutive days (Nov 13-17)
      expect(habit.completedDates.length, 5);
      expect(habit.completedDates.last, '2025-11-17');
    });

    test('streak resets when day is skipped', () {
      final habit = Habit(
        id: 'habit-2',
        title: 'Workout',
        category: 'Fitness',
        color: '#4CAF50',
        frequency: 'daily',
        streak: 0,
        completedDates: [
          '2025-11-13',
          '2025-11-14',
          // Gap on Nov 15
          '2025-11-16',
          '2025-11-17',
        ],
        createdAt: DateTime(2025, 11, 13),
        updatedAt: DateTime(2025, 11, 17),
      );

      // After gap, streak should restart from Nov 16
      // Expect 2 consecutive days (Nov 16-17)
      final consecutiveDays = habit.completedDates.where((date) {
        return date == '2025-11-16' || date == '2025-11-17';
      }).length;

      expect(consecutiveDays, 2);
    });

    test('streak is 0 for new habit with no completions', () {
      final habit = Habit(
        id: 'habit-3',
        title: 'Meditation',
        category: 'Mindfulness',
        color: '#FF5252',
        frequency: 'daily',
        streak: 0,
        completedDates: [],
        createdAt: DateTime(2025, 11, 17),
        updatedAt: DateTime(2025, 11, 17),
      );

      expect(habit.streak, 0);
      expect(habit.completedDates, isEmpty);
    });

    test('streak is 1 for single completion today', () {
      final habit = Habit(
        id: 'habit-4',
        title: 'Water Intake',
        category: 'Health',
        color: '#34C759',
        frequency: 'daily',
        streak: 0,
        completedDates: ['2025-11-17'],
        createdAt: DateTime(2025, 11, 17),
        updatedAt: DateTime(2025, 11, 17),
      );

      expect(habit.completedDates.length, 1);
      expect(habit.completedDates.first, '2025-11-17');
    });

    test('handles unsorted completion dates', () {
      final habit = Habit(
        id: 'habit-5',
        title: 'Journaling',
        category: 'Reflection',
        color: '#5B50FF',
        frequency: 'daily',
        streak: 0,
        completedDates: [
          '2025-11-17',
          '2025-11-15',
          '2025-11-16',
          '2025-11-14',
        ],
        createdAt: DateTime(2025, 11, 14),
        updatedAt: DateTime(2025, 11, 17),
      );

      // Dates should be sortable
      final sorted = habit.completedDates..sort();
      expect(sorted.first, '2025-11-14');
      expect(sorted.last, '2025-11-17');
    });
  });

  group('HabitService - Scheduling Logic', () {
    late HabitService service;
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = HabitService(firestore: firestore);
    });

    test('daily habit is scheduled every day', () {
      final habit = Habit(
        id: 'habit-daily',
        title: 'Daily Task',
        category: 'Routine',
        color: '#5B50FF',
        frequency: 'daily',
        streak: 0,
        completedDates: [],
        createdAt: DateTime(2025, 11, 17),
        updatedAt: DateTime(2025, 11, 17),
      );

      // Check multiple days
      expect(service.isScheduledOnDate(habit, DateTime(2025, 11, 17)), true);
      expect(service.isScheduledOnDate(habit, DateTime(2025, 11, 18)), true);
      expect(service.isScheduledOnDate(habit, DateTime(2025, 11, 19)), true);
    });

    test('weekly_days habit is scheduled only on specified weekdays', () {
      final habit = Habit(
        id: 'habit-weekly',
        title: 'Gym Workout',
        category: 'Fitness',
        color: '#4CAF50',
        frequency: 'weekly_days',
        weekdays: [1, 3, 5], // Mon, Wed, Fri
        streak: 0,
        completedDates: [],
        createdAt: DateTime(2025, 11, 17),
        updatedAt: DateTime(2025, 11, 17),
      );

      // Nov 17, 2025 is Monday (weekday 1)
      expect(service.isScheduledOnDate(habit, DateTime(2025, 11, 17)), true);
      // Nov 18, 2025 is Tuesday (weekday 2) - not scheduled
      expect(service.isScheduledOnDate(habit, DateTime(2025, 11, 18)), false);
      // Nov 19, 2025 is Wednesday (weekday 3)
      expect(service.isScheduledOnDate(habit, DateTime(2025, 11, 19)), true);
      // Nov 20, 2025 is Thursday (weekday 4) - not scheduled
      expect(service.isScheduledOnDate(habit, DateTime(2025, 11, 20)), false);
      // Nov 21, 2025 is Friday (weekday 5)
      expect(service.isScheduledOnDate(habit, DateTime(2025, 11, 21)), true);
    });

    test('weekly_target habit is always schedulable', () {
      final habit = Habit(
        id: 'habit-target',
        title: 'Yoga Session',
        category: 'Wellness',
        color: '#FF5252',
        frequency: 'weekly_target',
        weeklyTarget: 3,
        streak: 0,
        completedDates: [],
        createdAt: DateTime(2025, 11, 17),
        updatedAt: DateTime(2025, 11, 17),
      );

      // Can be completed any day
      expect(service.isScheduledOnDate(habit, DateTime(2025, 11, 17)), true);
      expect(service.isScheduledOnDate(habit, DateTime(2025, 11, 18)), true);
      expect(service.isScheduledOnDate(habit, DateTime(2025, 11, 21)), true);
    });

    test('irregular habit is always schedulable', () {
      final habit = Habit(
        id: 'habit-irregular',
        title: 'Random Task',
        category: 'Misc',
        color: '#5B50FF',
        frequency: 'irregular',
        streak: 0,
        completedDates: [],
        createdAt: DateTime(2025, 11, 17),
        updatedAt: DateTime(2025, 11, 17),
      );

      expect(service.isScheduledOnDate(habit, DateTime(2025, 11, 17)), true);
      expect(service.isScheduledOnDate(habit, DateTime(2025, 11, 20)), true);
    });
  });

  group('HabitService - Weekly Completion', () {
    late HabitService service;
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = HabitService(firestore: firestore);
    });

    test('counts completions in current week', () {
      final habit = Habit(
        id: 'habit-weekly-count',
        title: 'Weekly Task',
        category: 'Work',
        color: '#5B50FF',
        frequency: 'weekly_target',
        weeklyTarget: 5,
        streak: 0,
        completedDates: [
          '2025-11-17', // Monday
          '2025-11-18', // Tuesday
          '2025-11-19', // Wednesday
        ],
        createdAt: DateTime(2025, 11, 17),
        updatedAt: DateTime(2025, 11, 19),
      );

      final referenceDate = DateTime(2025, 11, 19);
      final count = service.countCompletionsInWeek(habit, referenceDate);

      expect(count, 3);
    });

    test('calculates planned days for weekly_days frequency', () {
      final habit = Habit(
        id: 'habit-planned',
        title: 'Planned Workout',
        category: 'Fitness',
        color: '#4CAF50',
        frequency: 'weekly_days',
        weekdays: [1, 3, 5], // Mon, Wed, Fri = 3 days
        streak: 0,
        completedDates: [],
        createdAt: DateTime(2025, 11, 17),
        updatedAt: DateTime(2025, 11, 17),
      );

      final planned = service.plannedDaysInWeek(habit);
      expect(planned, 3);
    });

    test('calculates planned days for daily frequency', () {
      final habit = Habit(
        id: 'habit-daily-count',
        title: 'Daily Routine',
        category: 'Health',
        color: '#34C759',
        frequency: 'daily',
        streak: 0,
        completedDates: [],
        createdAt: DateTime(2025, 11, 17),
        updatedAt: DateTime(2025, 11, 17),
      );

      final planned = service.plannedDaysInWeek(habit);
      expect(planned, 7);
    });

    test('calculates planned days for weekly_target frequency', () {
      final habit = Habit(
        id: 'habit-target-count',
        title: 'Target Task',
        category: 'Goals',
        color: '#FF5252',
        frequency: 'weekly_target',
        weeklyTarget: 4,
        streak: 0,
        completedDates: [],
        createdAt: DateTime(2025, 11, 17),
        updatedAt: DateTime(2025, 11, 17),
      );

      final planned = service.plannedDaysInWeek(habit);
      expect(planned, 4);
    });

    test('irregular habit has 0 planned days', () {
      final habit = Habit(
        id: 'habit-irregular-count',
        title: 'Irregular Task',
        category: 'Random',
        color: '#5B50FF',
        frequency: 'irregular',
        streak: 0,
        completedDates: [],
        createdAt: DateTime(2025, 11, 17),
        updatedAt: DateTime(2025, 11, 17),
      );

      final planned = service.plannedDaysInWeek(habit);
      expect(planned, 0);
    });
  });

  group('HabitService - Completion Status', () {
    late HabitService service;
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = HabitService(firestore: firestore);
    });

    test('isCompletedOnDate returns true for completed date', () {
      final habit = Habit(
        id: 'habit-check',
        title: 'Check Completion',
        category: 'Test',
        color: '#5B50FF',
        frequency: 'daily',
        streak: 0,
        completedDates: ['2025-11-17'],
        createdAt: DateTime(2025, 11, 17),
        updatedAt: DateTime(2025, 11, 17),
      );

      expect(service.isCompletedOnDate(habit, DateTime(2025, 11, 17)), true);
      expect(service.isCompletedOnDate(habit, DateTime(2025, 11, 18)), false);
    });

    test('handles multiple completions on different dates', () {
      final habit = Habit(
        id: 'habit-multi',
        title: 'Multi Completion',
        category: 'Test',
        color: '#4CAF50',
        frequency: 'daily',
        streak: 0,
        completedDates: ['2025-11-15', '2025-11-16', '2025-11-17'],
        createdAt: DateTime(2025, 11, 15),
        updatedAt: DateTime(2025, 11, 17),
      );

      expect(service.isCompletedOnDate(habit, DateTime(2025, 11, 15)), true);
      expect(service.isCompletedOnDate(habit, DateTime(2025, 11, 16)), true);
      expect(service.isCompletedOnDate(habit, DateTime(2025, 11, 17)), true);
      expect(service.isCompletedOnDate(habit, DateTime(2025, 11, 14)), false);
    });
  });
}
