@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reflecto/screens/home_screen.dart' as app;
import 'package:reflecto/providers/streak_providers.dart' as streak;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Keine Firebase-Initialisierung notwendig: HomeScreen fängt fehlende Init ab.
  const runGoldens = bool.hasEnvironment('RUN_GOLDENS');

  Future<void> pumpWithSize(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(child);
    await tester.pumpAndSettle();
  }

  testWidgets('HomeScreen golden', (tester) async {
    final scope = ProviderScope(
      overrides: [
        streak.streakInfoProvider.overrideWith(
          (ref) => const streak.StreakInfo(current: 5, longest: 10),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const app.HomeScreen(),
      ),
    );
    await pumpWithSize(tester, scope);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('home.png'));
  }, skip: !runGoldens);
}
