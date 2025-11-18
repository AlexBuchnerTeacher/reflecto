# Test Strategy

**Version:** v1.6.1  
**Coverage Goal:** 50% (core modules), dann schrittweise auf 70%

---

## 🎯 Test-Pyramide

```
        /\
       /  \        E2E / Integration (2-3 critical flows)
      /----\
     /      \       Widget Tests (UI components)
    /--------\
   /          \     Unit Tests (Services, Providers, Models)
  /------------\
```

### 1. Unit Tests (Basis: 50%+ Coverage)

**Ziel:** Business-Logik isoliert testen ohne UI/Firebase.

**Priorität:**
- ✅ `HabitService`: `calculateHabitPriority()`, `sortHabitsByPriority()`, `isScheduledOnDate()`
- ✅ `HabitTemplateService`: Template seeding, CRUD
- ⚠️ `FirestoreService`: Mocking mit `fake_cloud_firestore`
- ⚠️ Providers: AsyncNotifier Tests mit `ProviderContainer`

**Lokales Ausführen:**
```bash
flutter test test/unit/
```

**CI:** Automatisch in `.github/workflows/test.yml`

---

### 2. Widget Tests (UI ohne Backend)

**Ziel:** UI-Komponenten isoliert testen, Interaktionen verifizieren.

**Priorität:**
- ⚠️ `HabitCard`: Checkbox, Streak-Anzeige, Priority Badge
- ⚠️ `HabitInsightsCard`: Tagesbilanz, Kategorie-Progress
- ⚠️ `MealTrackerCard`: Collapsible, TimePicker
- ⚠️ `ReflectoCard`: Collapsible Animation

**Beispiel:**
```dart
testWidgets('HabitCard shows priority badge when enabled', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: HabitCard(
          habit: testHabit,
          showPriority: true,
        ),
      ),
    ),
  );
  expect(find.text('🔥'), findsOneWidget);
});
```

**Lokales Ausführen:**
```bash
flutter test test/widget/
```

---

### 3. Golden Tests (Visual Regression)

**Ziel:** UI-Änderungen deterministisch erkennen.

**Priorität (v1.7.0+):**
- `WeekScreen` (Hero Card, Radial Stats)
- `HabitScreen` (mit Insights Card)
- `DayScreen` (Morning/Evening Sections)

**Lokales Ausführen:**
```bash
flutter test --update-goldens  # Baselines erstellen
flutter test test/golden/      # Vergleichen
```

**CI:** Automatisch in `flutter-ci.yml` (Update nur manuell)

---

### 4. Integration Tests (E2E)

**Ziel:** Kritische User Flows End-to-End testen.

**Priorität (v1.7.0):**
- Login → Create Habit → Complete Habit → Verify Streak
- Weekly Reflection Snapshot → View Week Screen
- Meal Tracker Time Selection → Firestore Sync

**Setup:**
```bash
cd integration_test
flutter test integration_test/app_test.dart -d chrome
```

**CI:** Separater Job mit Firebase Emulator (siehe unten)

---

## 🔥 Firebase Emulator Tests

**Ziel:** Firestore Rules + Auth testen ohne Prod DB.

**Setup (lokal):**
```bash
npm install -g firebase-tools
firebase emulators:start --only firestore,auth
flutter test test/firestore/
```

**CI Integration:** Siehe `.github/workflows/test.yml` → `firebase-emulator` Job

**Rules Tests:**
```bash
firebase emulators:exec --only firestore "flutter test test/firestore/rules_test.dart"
```

---

## 📊 Coverage Reports

**Lokal generieren:**
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS/Linux
start coverage/html/index.html # Windows
```

**CI:** Automatisch zu Codecov hochgeladen → Badge in README

**Schwellwert:** 50% (aktuell), Ziel: 70% bis v1.8.0

---

## 🚨 Bekannte Issues

**Firebase Mock fehlt:**
- 11 Tests in `habit_service_test.dart` failen (siehe #103)
- Lösung: `fake_cloud_firestore` oder `firebase_core` stub

**Golden Tests:**
- Noch nicht implementiert (v1.7.0)
- Font rendering kann zwischen CI/lokal abweichen → `flutter_test_config.dart` mit `loadFonts()`

---

## 📁 Test-Dateistruktur

```
test/
├── unit/
│   ├── habit_service_test.dart
│   ├── habit_model_test.dart
│   └── providers/
│       └── streak_providers_test.dart
├── widget/
│   ├── habit_card_test.dart
│   └── meal_tracker_card_test.dart
├── golden/
│   └── week_screen_golden_test.dart
├── firestore/
│   └── rules_test.dart
└── integration_test/
    └── app_test.dart
```

---

## 🔄 Test Workflow

1. **Entwicklung:** Unit Tests parallel zu Feature schreiben
2. **PR:** CI führt alle Tests aus (format, analyze, unit, widget)
3. **Review:** Coverage-Bericht in PR-Comment (Codecov)
4. **Merge:** Golden Tests + E2E optional (bei UI-Changes Pflicht)
5. **Release:** Vollständige Testsuite + Firebase Emulator

---

## 🎯 Nächste Schritte

- [ ] Firebase Mock Setup (#103)
- [ ] Widget Tests für Collapsible Cards (#114 follow-up)
- [ ] Golden Tests für Week/Habit/Day Screens
- [ ] Integration Test: Auth + Habit CRUD
- [ ] Coverage-Ziel auf 70% erhöhen (v1.8.0)

---

**Fragen? Siehe:** `CONTRIBUTING.md` oder `MAINTAINER_GUIDE.md`
