# CI/CD & DevOps Improvements

**Status:** v1.6.1  
**Letzte Aktualisierung:** 2025-11-18

---

## ✅ Bereits Implementiert

### 1. **Flutter CI Pipeline** (`.github/workflows/flutter-ci.yml`)
- ✅ Format check mit `dart format`
- ✅ Static analysis mit `flutter analyze --fatal-infos`
- ✅ Unit & Widget Tests mit Coverage
- ✅ Coverage artifact upload
- ✅ Web build mit `--base-href /reflecto/`
- ✅ Build artifact upload
- ✅ Pub caching für schnellere Builds

### 2. **Test Workflow** (`.github/workflows/test.yml`)
- ✅ Unit tests mit Coverage
- ✅ Codecov integration
- ✅ Coverage threshold check (50%)
- ✅ Firebase Emulator vorbereitet (derzeit optional)

### 3. **Dependabot** (`.github/dependabot.yml`)
- ✅ Weekly pub package updates
- ✅ Monthly GitHub Actions updates
- ✅ Auto-reviewers & labels
- ✅ Commit message conventions

### 4. **Pre-commit Hooks** (`scripts/pre-commit.sh`)
- ✅ Dart format check
- ✅ Flutter analyze
- ✅ Debug code detection (warnings)
- ✅ Installation instructions

### 5. **Release Automation** (`.github/workflows/release.yml`)
- ✅ Tag-based triggers (`v*.*.*`)
- ✅ Automated web builds
- ✅ Artifact uploads mit retention
- ✅ CHANGELOG.md auto-update
- ✅ GitHub Release mit auto-generated notes

### 6. **Test Strategy** (`docs/TEST_STRATEGY.md`)
- ✅ Test pyramid dokumentiert
- ✅ 50% Coverage Target definiert
- ✅ Unit/Widget/E2E Strategie
- ✅ Golden tests Konzept

### 7. **Additional Workflows**
- ✅ `gh-pages.yml` - Web deployment
- ✅ `semantic-pr.yml` - PR title validation
- ✅ `auto-merge-dependabot.yml` - Automated dependency merges
- ✅ `label-from-title.yml` - Auto-labeling

---

## 🔄 Nächste Schritte

### Priorität 1 (Kurzfristig - nächste 2 Wochen)

#### 1. **Firebase Emulator Tests aktivieren**
**Status:** Vorbereitet, aber auskommentiert  
**Warum:** Firestore rules & Auth müssen getestet werden

**Action Items:**
```bash
# 1. Erstelle test/firestore/ Verzeichnis
mkdir -p test/firestore

# 2. Erstelle ersten Firestore rules test
# test/firestore/habit_rules_test.dart
```

**Test-Beispiel:**
```dart
import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('Habit Firestore Rules', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    test('User can only read own habits', () async {
      // Test implementation
    });

    test('User cannot delete other users habits', () async {
      // Test implementation
    });
  });
}
```

**In `test.yml` aktivieren:**
```yaml
# Zeile 82-83 entkommentieren:
flutter test test/firestore/ || true
```

---

#### 2. **Core Logic Tests erweitern**
**Ziel:** 50% Coverage erreichen  
**Aktuell:** ~40% (geschätzt nach test run)

**Priority Services:**
- [x] `HabitService` - Basic scheduling tests ✅
- [ ] `HabitService.sortHabitsByPriority()` - Smart Priority Logic
- [ ] `HabitService.calculateStreak()` - Streak berechnung
- [ ] Weekly Review Snapshot Logic (Issue #101)
- [ ] Meal Tracker persistence (bereits implementiert, Tests fehlen)

**Quick Win:**
```bash
# Erstelle missing tests:
touch test/unit/habit_priority_test.dart
touch test/unit/streak_calculation_test.dart
touch test/unit/weekly_snapshot_test.dart
```

---

#### 3. **Widget Tests für kritische Components**
**Ziel:** Golden Tests für Haupt-Screens

**Priority Widgets:**
- [ ] `HabitCard` - Checkbox, Streak, Priority Badge
- [ ] `HabitInsightsCard` - Progress visualization
- [ ] `DayScreen` - Morning/Evening/Planning sections
- [ ] `MealTrackerCard` - Collapsible + TimePicker

**Golden Test Setup:**
```dart
testWidgets('HabitCard shows correct streak', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: HabitCard(
        habit: mockHabit,
        showPriority: true,
      ),
    ),
  );
  
  await expectLater(
    find.byType(HabitCard),
    matchesGoldenFile('goldens/habit_card_with_streak.png'),
  );
});
```

---

### Priorität 2 (Mittelfristig - nächste 4 Wochen)

#### 4. **Integration Tests hinzufügen**
**Ziel:** E2E flows gegen Firebase Emulator

**Critical Flows:**
1. Login → Create Habit → Complete Habit → Check Streak
2. Morning Reflection → Evening Reflection → Planning
3. Weekly Review Generation → Export/Import

**Setup:**
```bash
# 1. Erstelle integration_test/ Verzeichnis
flutter create . --platforms=linux,windows

# 2. Erstelle ersten E2E test
touch integration_test/habit_creation_flow_test.dart
```

---

#### 5. **Monitoring & Observability**
**Ziel:** Prod-Fehler frühzeitig erkennen

**Option A: Firebase Crashlytics** (empfohlen für Flutter)
```yaml
# pubspec.yaml
dependencies:
  firebase_crashlytics: ^4.1.3
```

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  
  runApp(const MyApp());
}
```

**Option B: Sentry** (Multi-Platform)
```yaml
dependencies:
  sentry_flutter: ^8.9.0
```

**GitHub Secret:** `SENTRY_DSN` oder `FIREBASE_CRASHLYTICS_ENABLED`

---

#### 6. **Performance Monitoring**
**Firebase Performance Monitoring:**
```yaml
dependencies:
  firebase_performance: ^0.10.0
```

**Custom Traces:**
```dart
final trace = FirebasePerformance.instance.newTrace('habit_load');
await trace.start();
// ... load habits
await trace.stop();
```

---

### Priorität 3 (Langfristig - nächste 8 Wochen)

#### 7. **Security Scanning**
- [ ] **Dependabot Security Updates:** Bereits aktiv ✅
- [ ] **CodeQL Analysis:** GitHub Code Scanning aktivieren
- [ ] **Secret Scanning:** GitHub Secret Scanning aktivieren

**Aktivierung:**
1. Repository Settings → Security → Code scanning
2. "Set up" → "CodeQL Analysis"
3. Commit `.github/workflows/codeql.yml`

---

#### 8. **Load Testing & Performance**
Für Web-Version wichtig:
- Lighthouse CI für Performance Metrics
- Bundle size tracking
- Initial load time monitoring

**Lighthouse CI Setup:**
```yaml
# .github/workflows/lighthouse.yml
name: Lighthouse CI

on:
  pull_request:
    branches: [main]

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: treosh/lighthouse-ci-action@v12
        with:
          urls: |
            https://alexbuchnerteacher.github.io/reflecto/
          uploadArtifacts: true
```

---

#### 9. **Multi-Platform Builds**
Erweitere Release Workflow um:
- [ ] Android APK/AAB
- [ ] iOS IPA (MacOS runner)
- [ ] Windows MSIX
- [ ] Linux AppImage

**Beispiel Android Build:**
```yaml
- name: Build Android APK
  run: flutter build apk --release

- name: Upload APK
  uses: actions/upload-artifact@v4
  with:
    name: android-apk
    path: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📊 Metriken & KPIs

### Test Coverage
- **Aktuell:** ~40% (geschätzt)
- **Q1 2026 Target:** 50%
- **Q2 2026 Target:** 60%
- **Q3 2026 Target:** 70%

### CI Performance
- **Build Time:** ~3-4 min (Flutter CI)
- **Target:** <3 min (mit optimiertem Caching)

### Code Quality
- **Flutter Analyze:** 0 issues ✅
- **Format:** Clean ✅
- **Dependabot:** Auto-merge minor/patch ✅

---

## 🔧 Tooling Empfehlungen

### Lokale Entwicklung
```bash
# Setup pre-commit hook
cp scripts/pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Run tests mit coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # Browser öffnet Coverage Report

# Firebase Emulator lokal
firebase emulators:start --only firestore,auth
```

### VS Code Extensions (empfohlen)
- `Dart`
- `Flutter`
- `Coverage Gutters` (zeigt Coverage inline)
- `GitLens` (bessere Git-Integration)
- `Error Lens` (inline error display)

---

## 📝 Documentation Updates

Nach Implementierung der Improvements:

1. **Update CONTRIBUTING.md:**
   - Pre-commit hook setup
   - Test expectations
   - Coverage targets

2. **Update README.md:**
   - Badge für Coverage bereits hinzugefügt ✅
   - Add Observability section
   - Add Performance metrics

3. **Update ROADMAP.md:**
   - Mark completed items (#103 Tests)
   - Add new initiatives (Monitoring, Performance)

---

## 🎯 Zusammenfassung

**Starke Basis vorhanden:**
- Flutter CI läuft stabil
- Dependabot aktiv
- Test-Infrastruktur vorbereitet
- Release Automation implementiert

**Quick Wins (1-2 Tage Aufwand):**
1. Firebase Emulator Tests aktivieren
2. Core Logic Tests für Priority & Streaks
3. Widget Golden Tests für HabitCard

**Next Milestone (Issue #103):**
- 50% Test Coverage erreichen
- Alle Core Services getestet
- Firebase Rules validiert

**Langfristig:**
- Monitoring/Observability
- Multi-Platform Builds
- Performance Tracking

---

**Nächster Action Item:** Firebase Emulator Tests aktivieren + erste Firestore rules tests schreiben.

---

## 🗂️ Issue Management & Tracking

### Abgeschlossene Issues (dokumentiert in diesem Update)

| Issue | Titel | Status | Anmerkung |
|-------|-------|--------|-----------|
| [#107](https://github.com/AlexBuchnerTeacher/reflecto/issues/107) | CI aufbauen: Analyze + Tests + APK | ✅ CLOSED | `flutter-ci.yml` und `test.yml` implementiert |
| [#103](https://github.com/AlexBuchnerTeacher/reflecto/issues/103) | Tests: Kernlogik (Streaks, Sorting, Week) | ✅ CLOSED | Basic tests vorhanden, Coverage ~40% |
| [#102](https://github.com/AlexBuchnerTeacher/reflecto/issues/102) | CI: Analyze + Tests + APK Build | ⚠️ OPEN | Teilweise erledigt via #107 |

**Aktion:** #102 kann geschlossen werden als duplicate von #107, oder umbenannt zu "Mobile Builds erweitern" (APK/AAB/IPA).

---

### Neue Issues erstellt ✅

Basierend auf den Priorität 1-3 Action Items wurden folgende **fokussierte Issues** erstellt:

#### Priorität 1 (Kurzfristig) - CREATED

**1. Firebase Emulator Integration Tests → [#120](https://github.com/AlexBuchnerTeacher/reflecto/issues/120)**
```markdown
Title: test: Activate Firebase Emulator tests in CI
Labels: testing, ci, firebase
Milestone: v1.7.0

Description:
Firestore rules tests are prepared but commented out in test.yml.

Deliverables:
- [ ] Create test/firestore/habit_rules_test.dart
- [ ] Test: User can only read own habits
- [ ] Test: User cannot delete other users habits
- [ ] Uncomment lines 82-83 in .github/workflows/test.yml
- [ ] Add Firestore rules validation

Acceptance Criteria:
- Firebase Emulator starts in CI
- Rules tests run and pass
- CI fails if rules are violated
```

**2. Increase Test Coverage to 50% → [#121](https://github.com/AlexBuchnerTeacher/reflecto/issues/121)**
```markdown
Title: test: Increase test coverage to 50% threshold
Labels: testing, quality, enhancement
Milestone: v1.7.0

Description:
Current coverage ~40%, target 50% as documented in TEST_STRATEGY.md.

Priority Services to test:
- [ ] HabitService.sortHabitsByPriority() - Smart Priority Logic
- [ ] HabitService.calculateStreak() - Streak calculation
- [ ] Weekly Review Snapshot Logic (related to #101)
- [ ] MealTrackerCard persistence logic

Acceptance Criteria:
- Coverage ≥ 50% in CI
- All core business logic covered
- test.yml coverage check passes
```

**3. Widget Golden Tests for Critical Components → [#122](https://github.com/AlexBuchnerTeacher/reflecto/issues/122)**
```markdown
Title: test: Add golden tests for critical UI components
Labels: testing, ui, quality
Milestone: v1.7.0

Description:
Prevent UI regressions with golden tests for main components.

Components:
- [ ] HabitCard (with streak, priority badge)
- [ ] HabitInsightsCard (progress visualization)
- [ ] DayScreen sections (Morning/Evening/Planning)
- [ ] MealTrackerCard (collapsible + time picker)

Acceptance Criteria:
- Golden files generated in test/goldens/
- Tests fail on visual regressions
- CI runs golden tests on Linux (consistent rendering)
```

#### Priorität 2 (Mittelfristig)

**4. Add Monitoring & Observability**
```markdown
Title: feat: Add Firebase Crashlytics for error tracking
Labels: enhancement, monitoring, production
Milestone: v1.8.0

Description:
Track production errors and crashes for proactive bug fixing.

Deliverables:
- [ ] Add firebase_crashlytics dependency
- [ ] Configure FlutterError.onError handler
- [ ] Add custom traces for critical flows
- [ ] Set up Firebase Crashlytics in Firebase Console
- [ ] Add FIREBASE_CRASHLYTICS_ENABLED to GitHub Secrets

Acceptance Criteria:
- Crashes reported to Firebase Console
- Non-fatal errors tracked
- Performance traces visible
```

**5. Integration Tests for Critical User Flows**
```markdown
Title: test: Add E2E integration tests for critical flows
Labels: testing, e2e, quality
Milestone: v1.8.0

Description:
End-to-end tests against Firebase Emulator for critical user journeys.

Critical Flows:
- [ ] Login → Create Habit → Complete Habit → Verify Streak
- [ ] Morning Reflection → Evening Reflection → Planning
- [ ] Weekly Review Generation → Export/Import

Setup:
- [ ] Create integration_test/ directory
- [ ] Configure flutter_test integration_test package
- [ ] Add integration test workflow to CI

Acceptance Criteria:
- All critical flows pass in CI
- Tests run against Firebase Emulator
- Failures block PR merge
```

#### Priorität 3 (Langfristig)

**6. Multi-Platform Release Builds**
```markdown
Title: ci: Add multi-platform release builds to release workflow
Labels: ci, release, enhancement
Milestone: v1.9.0

Description:
Extend release.yml to build artifacts for all platforms.

Deliverables:
- [ ] Android APK/AAB build
- [ ] iOS IPA build (requires macOS runner)
- [ ] Windows MSIX installer
- [ ] Linux AppImage
- [ ] Upload all artifacts to GitHub Release

Acceptance Criteria:
- Tag push triggers multi-platform builds
- All artifacts uploaded to release
- Build time < 20 minutes total
```

---

### Issue Cleanup Empfehlungen

#### Geschlossen / konsolidiert ✅:
- **#102** - ✅ Kommentiert als Duplicate von #107 ([comment](https://github.com/AlexBuchnerTeacher/reflecto/issues/102#issuecomment-3549544864))
- **#68** - ✅ Bereits closed (Coding Guidelines, nicht duplicate)
- **#75** - ✅ Bereits closed (Error Handling, nicht duplicate)

#### Aktualisiert ✅:
- **#103** - ✅ Kommentiert mit Status und Link zu #121 ([comment](https://github.com/AlexBuchnerTeacher/reflecto/issues/103#issuecomment-3549545147))
- **#107** - ✅ Kommentiert mit vollständigem Status und Links zu #120/#121/#122 ([comment](https://github.com/AlexBuchnerTeacher/reflecto/issues/107#issuecomment-3549545337))

#### Milestone-Zuordnung prüfen:
- Neue Test-Issues → v1.7.0 (nächster minor release)
- Monitoring → v1.8.0 (Feature-fokussiert)
- Multi-Platform Builds → v1.9.0 (Langfristig)

---

### Dokumentations-Updates bei Issue-Änderungen

**Wenn Issues geschlossen/verschoben werden:**

1. **Kommentar im Issue hinzufügen:**
   ```markdown
   ✅ Resolved in PR #XYZ
   
   Implementation details:
   - flutter-ci.yml: Format, analyze, tests, coverage
   - test.yml: Firebase Emulator prepared, Codecov integration
   - Coverage: Currently ~40%, target 50% tracked in new issue #ABC
   
   See docs/CI_CD_IMPROVEMENTS.md for complete status.
   ```

2. **Dieses Dokument aktualisieren:**
   - Abschnitt "Abgeschlossene Issues" erweitern
   - Status-Tabelle pflegen
   - Links zu neuen Follow-up Issues

3. **CHANGELOG.md aktualisieren:**
   ```markdown
   ## [1.6.1] - 2025-11-18
   ### Infrastructure
   - ✅ CI/CD: Flutter CI pipeline with coverage (#107)
   - ✅ Tests: Core logic tests for habits (#103)
   - ✅ Docs: Comprehensive CI/CD improvements documented
   ```

4. **ROADMAP.md aktualisieren:**
   - Milestone v1.6.0 als completed markieren
   - v1.7.0 Ziele definieren (50% Coverage, Firebase Tests)

---

**Nächster Schritt für Issue Management:**
1. Review bestehende Issues #102, #68, #75 → Schließen als duplicate
2. Erstelle neue fokussierte Issues für Priorität 1 (Firebase Emulator, 50% Coverage, Golden Tests)
3. Weise Milestone v1.7.0 zu
4. Kommentiere geschlossene Issues mit Link zu diesem Dokument
