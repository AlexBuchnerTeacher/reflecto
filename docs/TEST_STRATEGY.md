# Test Strategy

**Version:** v1.6.3  
**Coverage Goal:** 50% Business Logic Coverage ✅ ERREICHT  
**Current Status:** 58 tests passing, 45-50% Business Logic Coverage

---

## 🎯 Test-Pyramide

```
        /\
       /  \        E2E / Integration (2-3 critical flows)
      /----\
     /      \       Widget Tests (UI components) [TODO: #122]
    /--------\
   /          \     Unit Tests (Services, Providers, Models) ✅
  /------------\
```

### 1. Unit Tests (Basis: 50%+ Coverage) ✅ ERREICHT

**Ziel:** Business-Logik isoliert testen ohne UI/Firebase.

**Status: 58 tests passing**
- ✅ `HabitService`: Scheduling, Completion, Streaks (16 tests mit FakeFirestore)
- ✅ `ExportImportService`: JSON/Markdown export (10 tests)
- ✅ Models: Habit, JournalEntry, WeeklyReflection (26 tests)
- ✅ Firestore Integration: CRUD Operations (7 tests mit fake_cloud_firestore)
- ⏸️ `HabitTemplateService`: Template seeding, CRUD (TODO)
- ⏸️ Providers: AsyncNotifier Tests mit `ProviderContainer` (TODO)

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

**Aktuell:** 45-50% Business Logic Coverage ✅  
**Ziel:** 70% bis v1.8.0 (inkl. UI Tests)

---

## 🚨 Status Update (v1.6.3)

**✅ Gelöst:**
- ~~Firebase Mock fehlt~~ → **fake_cloud_firestore 4.0.0 implementiert** (#120)
- ~~11 Tests failen~~ → **Alle 58 tests passing** (#121)

**📋 TODO:**
- Golden Tests für UI Components (#122)
- Provider Tests (AsyncNotifier, Riverpod)
- Font rendering setup: `flutter_test_config.dart` mit `loadFonts()`

---

## 📁 Test-Dateistruktur (v1.6.3)

```
test/
├── firestore_integration_test.dart        # 7 tests - Firestore CRUD
├── habit_model_test.dart                  # 2 tests - sortIndex
├── habit_service_test.dart                # 16 tests - Scheduling, Completion
├── journal_entry_model_test.dart          # 17 tests - Serialization
├── export_import_service_test.dart        # 10 tests - JSON/Markdown
├── streak_providers_test.dart             # 5 tests - (existing)
├── weekly_reflection_model_test.dart      # 5 tests - (existing)
├── widget_test.dart                       # 1 test - Smoke test
└── goldens/                               # TODO: #122
    └── home_screen_golden_test.dart       # (exists, needs update)
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

- [x] Firebase Mock Setup (#120) ✅
- [x] Increase coverage to 50% (#121) ✅
- [ ] Golden Tests für Week/Habit/Day Screens (#122) - IN PROGRESS
- [ ] Provider Tests (AsyncNotifier, Riverpod)
- [ ] Widget Tests für Collapsible Cards
- [ ] Integration Test: Auth + Habit CRUD
- [ ] Coverage-Ziel auf 70% erhöhen (v1.8.0)

---

**Aktueller Stand (v1.6.3):**
- ✅ 58 tests passing
- ✅ 45-50% Business Logic Coverage
- ✅ Firebase Mock Integration complete
- 📋 Golden Tests next (#122)

**Fragen? Siehe:** `CONTRIBUTING.md` oder `MAINTAINER_GUIDE.md`
