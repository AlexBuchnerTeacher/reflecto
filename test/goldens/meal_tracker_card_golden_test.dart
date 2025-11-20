import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reflecto/features/day/widgets/meal_tracker_card.dart';
import 'package:reflecto/providers/card_collapse_providers.dart';
import 'package:reflecto/providers/meal_providers.dart';
import 'package:reflecto/services/meal_service.dart';

void main() {
  group('MealTrackerCard Golden Tests', () {
    late MealService mealService;
    late DateTime testDate;
    late SharedPreferences mockPrefs;

    setUp(() async {
      final fakeFirestore = FakeFirebaseFirestore();
      mealService = MealService(firestore: fakeFirestore);
      testDate = DateTime(2025, 11, 20);

      // Initialize SharedPreferences for tests
      SharedPreferences.setMockInitialValues({});
      mockPrefs = await SharedPreferences.getInstance();
    });

    testWidgets('MealTrackerCard - empty state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mealServiceProvider.overrideWithValue(mealService),
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: Scaffold(
              body: MealTrackerCard(date: testDate),
            ),
          ),
        ),
      );

      // Wait for async data load
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MealTrackerCard),
        matchesGoldenFile('goldens/meal_tracker_empty.png'),
      );
    });
  });
}
