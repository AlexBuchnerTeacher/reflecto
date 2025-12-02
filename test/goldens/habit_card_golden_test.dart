@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:reflecto/features/habits/widgets/habit_card.dart';
import 'package:reflecto/models/habit.dart';
import 'package:reflecto/providers/habit_providers.dart';
import 'package:reflecto/services/habit_service.dart';

void main() {
  group('HabitCard Golden Tests', () {
    late Habit testHabit;
    late HabitService habitService;

    setUp(() {
      // Mock Firestore für HabitService
      final fakeFirestore = FakeFirebaseFirestore();
      habitService = HabitService(firestore: fakeFirestore);

      testHabit = Habit(
        id: 'test-habit-1',
        title: 'Meditation',
        category: 'Gesundheit',
        color: '#4CAF50',
        frequency: 'daily',
        streak: 0,
        completedDates: [],
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
    });

    testWidgets('HabitCard - normal state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitServiceProvider.overrideWithValue(habitService),
          ],
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: Scaffold(
              body: HabitCard(habit: testHabit),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(HabitCard),
        matchesGoldenFile('goldens/habit_card_normal.png'),
      );
    });

    testWidgets('HabitCard - with streak badge', (tester) async {
      final habitWithStreak = testHabit.copyWith(streak: 7);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitServiceProvider.overrideWithValue(habitService),
          ],
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: Scaffold(
              body: HabitCard(habit: habitWithStreak),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(HabitCard),
        matchesGoldenFile('goldens/habit_card_with_streak.png'),
      );
    });

    testWidgets('HabitCard - weekly progress', (tester) async {
      final weeklyHabit = testHabit.copyWith(
        frequency: 'weekly_days',
        weekdays: [1, 3, 5], // Mo, Mi, Fr
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitServiceProvider.overrideWithValue(habitService),
          ],
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: Scaffold(
              body: HabitCard(habit: weeklyHabit),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(HabitCard),
        matchesGoldenFile('goldens/habit_card_weekly.png'),
      );
    });

    testWidgets('HabitCard - with priority badge', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitServiceProvider.overrideWithValue(habitService),
          ],
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: Scaffold(
              body: HabitCard(
                habit: testHabit,
                showPriority: true,
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(HabitCard),
        matchesGoldenFile('goldens/habit_card_with_priority.png'),
      );
    });

    testWidgets('HabitCard - with all features', (tester) async {
      final fullHabit = testHabit.copyWith(
        streak: 14,
        frequency: 'weekly_target',
        weekdays: [1, 2, 3, 4, 5],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitServiceProvider.overrideWithValue(habitService),
          ],
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: Scaffold(
              body: HabitCard(
                habit: fullHabit,
                showPriority: true,
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(HabitCard),
        matchesGoldenFile('goldens/habit_card_full_features.png'),
      );
    });
  });
}
