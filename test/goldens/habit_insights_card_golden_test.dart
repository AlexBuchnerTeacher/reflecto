import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reflecto/features/habits/widgets/habit_insights_card.dart';
import 'package:reflecto/models/habit.dart';
import 'package:reflecto/providers/card_collapse_providers.dart';
import 'package:reflecto/services/habit_service.dart';

void main() {
  group('HabitInsightsCard Golden Tests', () {
    late HabitService habitService;
    late DateTime testDate;
    late SharedPreferences mockPrefs;

    setUp(() async {
      final fakeFirestore = FakeFirebaseFirestore();
      habitService = HabitService(firestore: fakeFirestore);
      testDate = DateTime(2025, 11, 20); // Mittwoch

      // Initialize SharedPreferences for tests
      SharedPreferences.setMockInitialValues({});
      mockPrefs = await SharedPreferences.getInstance();
    });

    testWidgets('HabitInsightsCard - with habits and progress', (tester) async {
      final habits = [
        Habit(
          id: '1',
          title: 'Meditation',
          category: 'Gesundheit',
          color: '#4CAF50',
          frequency: 'daily',
          streak: 7,
          completedDates: [],
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
        Habit(
          id: '2',
          title: 'Lesen',
          category: 'Lernen',
          color: '#2196F3',
          frequency: 'daily',
          streak: 3,
          completedDates: [],
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
        Habit(
          id: '3',
          title: 'Sport',
          category: 'Fitness',
          color: '#FF5722',
          frequency: 'weekly_days',
          weekdays: [1, 3, 5],
          streak: 14,
          completedDates: [],
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: Scaffold(
              body: HabitInsightsCard(
                habits: habits,
                service: habitService,
                today: testDate,
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(HabitInsightsCard),
        matchesGoldenFile('goldens/habit_insights_with_data.png'),
      );
    });

    testWidgets('HabitInsightsCard - empty state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: Scaffold(
              body: HabitInsightsCard(
                habits: [],
                service: habitService,
                today: testDate,
              ),
            ),
          ),
        ),
      );

      // Empty state sollte nichts rendern (SizedBox.shrink)
      expect(find.byType(HabitInsightsCard), findsOneWidget);
      expect(find.text('Habit-Insights'), findsNothing);
    });

    testWidgets('HabitInsightsCard - mixed categories', (tester) async {
      final habits = [
        Habit(
          id: '1',
          title: 'Meditation',
          category: 'Gesundheit',
          color: '#4CAF50',
          frequency: 'daily',
          streak: 5,
          completedDates: [],
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
        Habit(
          id: '2',
          title: 'Yoga',
          category: 'Gesundheit',
          color: '#4CAF50',
          frequency: 'daily',
          streak: 2,
          completedDates: [],
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
        Habit(
          id: '3',
          title: 'Programmieren',
          category: 'Lernen',
          color: '#2196F3',
          frequency: 'daily',
          streak: 10,
          completedDates: [],
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
        Habit(
          id: '4',
          title: 'Gitarre üben',
          category: 'Kreativität',
          color: '#9C27B0',
          frequency: 'daily',
          streak: 1,
          completedDates: [],
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: Scaffold(
              body: HabitInsightsCard(
                habits: habits,
                service: habitService,
                today: testDate,
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(HabitInsightsCard),
        matchesGoldenFile('goldens/habit_insights_mixed_categories.png'),
      );
    });
  });
}
