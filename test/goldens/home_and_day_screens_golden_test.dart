import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reflecto/screens/home_screen.dart' as app;
import 'package:reflecto/screens/day_screen.dart' as app;
import 'package:reflecto/providers/auth_providers.dart' as auth;
import 'package:reflecto/providers/entry_providers.dart' as entries;
import 'package:reflecto/providers/streak_providers.dart' as streak;

import '../fakes/firestore_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const runGoldens = bool.hasEnvironment('RUN_GOLDENS');

  Future<void> _pumpWithSize(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(390, 844),
  }) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue = size;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
    await tester.pumpWidget(child);
    await tester.pumpAndSettle();
  }

  group('goldens', () {
    testWidgets('HomeScreen golden', (tester) async {
      final scope = ProviderScope(
        overrides: [
          // Zeige z. B. 5 Tage Streak
          streak.streakInfoProvider.overrideWith(
            (ref) => const streak.StreakInfo(current: 5, longest: 10),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const app.HomeScreen(),
        ),
      );
      await _pumpWithSize(tester, scope);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('home.png'),
      );
    }, skip: !runGoldens);

    testWidgets('DayScreen golden', (tester) async {
      final today = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      final idToday = '${today.year}-${two(today.month)}-${two(today.day)}';
      final tomorrow = today.add(const Duration(days: 1));
      final idTomorrow =
          '${tomorrow.year}-${two(tomorrow.month)}-${two(tomorrow.day)}';

      final dayDataToday = <String, dynamic>{
        'planning': {
          'goals': ['Laufen', 'Lesen', ''],
          'todos': ['Einkaufen', 'Mail schreiben', ''],
          'reflection': 'Fokus auf Gesundheit',
          'notes': 'Notiztext',
        },
        'evening': {
          'completed': false,
          'good': 'Gutes Gespräch',
          'learned': 'Neues Rezept',
          'improve': '',
          'gratitude': 'Familie',
          'goalsCompletion': [true, false, false],
          'todosCompletion': [true, false, false],
        },
      };
      final dayDataTomorrow = <String, dynamic>{
        'planning': {
          'goals': ['Laufen', '', ''],
          'todos': ['Einkaufen', '', ''],
          'reflection': '',
          'notes': '',
        },
      };

      final scope = ProviderScope(
        overrides: [
          auth.userIdProvider.overrideWith((ref) => 'test-user'),
          entries.updateDayFieldProvider.overrideWith(
            (ref) =>
                (
                  String uid,
                  DateTime date,
                  String field,
                  dynamic value,
                ) async {},
          ),
          entries.dayDocProvider.overrideWith((ref, date) {
            final id = '${date.year}-${two(date.month)}-${two(date.day)}';
            final data = id == idToday ? dayDataToday : dayDataTomorrow;
            return Stream.value(
              FakeDocumentSnapshot<Map<String, dynamic>>(
                id: id,
                data: data,
                metadata: FakeSnapshotMetadata(
                  hasPendingWrites: false,
                  isFromCache: false,
                ),
              ),
            );
          }),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: app.DayScreen(initialDate: today),
        ),
      );

      await _pumpWithSize(tester, scope);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('day.png'));
    }, skip: !runGoldens);
  });
}
