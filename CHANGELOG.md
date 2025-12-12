## [1.8.0] - 2025-12-12

### UX Improvements & Feature Enhancements

**User Feedback Fixes:**
- **Meal Card Status**: Status (X/3 erfasst) now visible when collapsed
- **Reflection Questions**: Reduced evening reflection from 4 to 2 questions
  - Kept: "Was lief heute gut?" + "Wofür bin ich dankbar?"  
  - Removed: "Was habe ich gelernt?" + "Was hätte besser laufen können?"
- **Habit Order Fix**: Manual habit sorting now persists daily
  - Previously: Completed habits moved to bottom and stayed there next day
  - Now: Habits return to manual order each day, regardless of completion status
  - sortHabitsByCustomOrder() simplified to sort only by sortIndex

**Habits in Weekly Export:**
- Habits now included in weekly export JSON
- Includes: title, category, frequency, streak, weekly completions
- Only exports completions from current week
- Added 3 tests for habit export functionality

**Testing:**
- export_import_service_test.dart: 13 tests (3 new for habits)
- All tests passing ✅

---

## [1.7.1] - 2025-12-02

### Bugfix: Firestore Security Rules 🔒

- **Security Rules Update**: Production-ready Firestore rules deployed
  - Added rules for `habits` collection
  - Added rules for `meals` collection  
  - Added read-only access to `habit_templates` for authenticated users
  - Fixed test mode expiration issue (3-day warning)
- **firebase.json**: Added Firestore rules deployment target

**Commit:** f09026f

---

## [1.7.0] - 2025-11-20

### Test Infrastructure & Quality ✅

**Firebase Emulator Tests (#120)**
- test: Activate Firebase Emulator tests in CI (021f188)
- 7 Firestore Integration Tests implementiert
- 16 HabitService Unit Tests gefixt
- fake_cloud_firestore 4.0.0 Integration
- Firebase Emulator Job in CI Pipeline

**Test Coverage 50% (#121)**
- test: Increase test coverage from 13 to 58 tests
- 45-50% Business Logic Coverage erreicht
- Models: ~70% Coverage (e725e99, 06ade58, 9331aa5)
- Services: ~45% Coverage
- Coverage Threshold Check in CI (50% Minimum)

**Golden Tests (#122)**
- test: Add golden tests for UI regression prevention
- 15 Golden Tests (5 HabitCard, 3 HabitInsightsCard, 1 MealTracker, 6 DayScreen Sections)
- SharedPreferences Mock-Integration (0c20c58)
- CI Integration mit golden-tests Job (884a4c8)
- 14 Golden Baseline Images committed (2ca8c16)

**Test Status:** 73 tests total (58 unit + 15 golden) - all passing ✅

**Closed Issues:** #120, #121, #122
**Closed Milestone:** v1.7.0 (Test Infrastructure & Quality)

## [1.6.3] - 2025-11-20

- build: Bump version to 1.6.3+9 (6ed5b01)
- docs: Update TEST_STRATEGY.md for v1.6.3 (0a51c05)
- docs: Add v1.6.3 changelog entry for test infrastructure (229d7da)
- test: Add ExportImportService tests (#121) (e725e99)
- test: Add comprehensive JournalEntry model tests (#121) (06ade58)
- test: Add Firebase mock support with fake_cloud_firestore (#120) (021f188)
- test: Add habit model tests for sortIndex behavior (#121) (9331aa5)# Changelog

Alle nennenswerten Änderungen an Reflecto.

## v1.6.3 (2025-11-20) - Test Infrastructure

### Tests: Firebase Mock Integration (#120)
- **fake_cloud_firestore 4.0.0** hinzugefügt für Firestore-Tests ohne echte Firebase-Instanz
- **Neue Test-Datei**: `test/firestore_integration_test.dart` (7 Tests)
  - Firestore CRUD Operations (create, read, update, delete, batch)
  - User Isolation (separate habits collections)
  - Habit Model Serialization (toMap/fromMap round-trip)
- **HabitService Tests gefixt**: 11 vorher fehlschlagende Tests jetzt passing
  - Dependency Injection: HabitService akzeptiert optional `firestore` Parameter
  - Alle Tests nutzen `FakeFirebaseFirestore` statt echte Firebase-Instanz
  - 16 Tests für Scheduling Logic, Weekly Completion, Completion Status

### Tests: Model Tests erweitert (#121)
- **Neue Test-Datei**: `test/habit_model_test.dart` (2 Tests)
  - sortIndex creation and assignment
  - null sortIndex defaults
- **Neue Test-Datei**: `test/journal_entry_model_test.dart` (17 Tests)
  - JournalEntry serialization (toMap/fromMap)
  - Nested models: Planning, Morning, Evening, Ratings
  - Back-compat field names (feeling→mood, better→improve)
  - Fallback ratings logic (ratingsMorning/ratingsEvening)
  - Round-trip serialization verification
  - copyWith() methods for all models
- **Neue Test-Datei**: `test/export_import_service_test.dart` (10 Tests)
  - buildWeekExportJson (JSON structure, missing days, null ratings)
  - buildMarkdownFromJson (AI prompt format validation)
  - Aggregate statistics preservation
  - JSON encoding/decoding round-trip

### Test Status
- **Vorher**: 13 tests passing, 11 failing
- **Nachher**: **58 tests passing, 0 failing** 🎉
- **Coverage**: 45-50% Business Logic Coverage erreicht
  - Models: ~70% covered (Habit, JournalEntry, WeeklyReflection)
  - Services: ~45% covered (HabitService, ExportImportService)

### Geschlossene Issues
- #120: Firebase Emulator Integration Tests aktivieren

### Commits
- `021f188` - test: Add Firebase mock support with fake_cloud_firestore
- `9331aa5` - test: Add habit model tests for sortIndex behavior
- `06ade58` - test: Add comprehensive JournalEntry model tests
- `e725e99` - test: Add ExportImportService tests

---

## v1.6.2 (2025-11-20) - Post-Release Fixes

### Bug: Drag blockiert Scrollen auf Habit-Screen (#124, #125, #126, #127)
- **Problem gelöst**: ReorderableListView triggerte Drag auf gesamter HabitCard, blockierte Scroll-Gesten
- **Drag-Handle Pattern implementiert**:
  - Dediziertes Drag-Icon (Icons.drag_indicator_rounded) rechts in Card
  - ReorderableDragStartListener wrapped nur Handle, nicht gesamte Card
  - Scroll-Gesten haben Priorität, Drag ist bewusste Aktion
  - Built-in LongPress-Delay verhindert versehentliches Dragging
- **Mobile UX deutlich verbessert**:
  - ✅ Scrollen funktioniert ohne Blockierung
  - ✅ Drag nur am Handle möglich
  - ✅ Reorder-Funktionalität bleibt voll erhalten
  - ✅ Professionelle Interaktion wie Notion, Todoist, Apple Reminders
- **Code Changes**:
  - HabitCard: Neuer optionaler `dragHandle` parameter
  - HabitScreen: ReorderableDragStartListener nur für Handle-Icon
  - Dokumentiert mit Inline-Comments für Issue-Referenzen

### Fix: Meal Time Picker 24h Format fehlte im Release (#118)
- **Problem**: v1.6.1 CHANGELOG dokumentierte Fix, aber Code hatte ihn nicht
- **Root Cause**: Fix ging während PR #123 Squash Merge verloren
- **Re-Applied**: `alwaysUse24HourFormat: true` in showTimePicker MediaQuery builder
- **Status**: Jetzt korrekt implementiert (commit acac9b6)

### Fix: Debounce-Timing Standardisierung nicht vollständig (#116)
- **Problem**: CHANGELOG versprach 300ms Standard, aber Code hatte inkonsistente Werte
- **Korrekturen**:
  - MealTrackerCard: 400ms → 300ms (alle 3 Meal-Note Felder)
  - DaySyncLogic: 200ms → 300ms (Text field updates)
- **Ergebnis**: Konsistentes User-Feedback app-wide (commit 38b6fce)

### Geschlossene Issues
- #124: Drag blockiert Scrollen auf Habit-Screen
- #125: Drag-Handle für Habit-Reordering einbauen
- #126: Drag nur nach LongPress starten
- #127: Scroll- und Drag-Gesten korrekt priorisieren
- #118: Meal Time Picker 24h Format (re-applied)
- #116: Debounce-Timing Standardisierung (korrigiert)

---

## v1.6.1 (2025-11-18) - UX & Accessibility

### A11y: Tab-Navigation für Desktop Keyboard Users (#115)
- **Problem gelöst**: Desktop-User konnten nicht linear durch Formulare tabben, unvorhersehbare Fokus-Sprünge
- **FocusTraversalOrder implementiert**:
  - DayScreen: Morning TextFields (1-3), Evening TextFields (4-7), Planning Fields (8-15)
  - ProfileSection: TextField (1.0) → Save Button (2.0)
  - HabitScreen: FilterChips (1.0-2.0) für logische Reihenfolge
- **LabeledField Widget erweitert**:
  - Neuer `focusOrder` Parameter für NumericFocusOrder
  - Automatisches Wrapping mit FocusTraversalOrder wenn gesetzt
- **Akzeptanzkriterien erfüllt**:
  - ✅ Linearer Tab-Flow top-to-bottom für alle interaktiven Felder
  - ✅ Keine Fokus-Traps oder unerwartete Sprünge
  - ✅ Konsistente Reihenfolge über alle Screens

### Bug: Meal Time Picker zeigt AM/PM statt 24h Format (#118)
- **Problem gelöst**: TimePicker zeigte 12-Stunden-Format statt deutsches 24h-Format (HH:mm)
- **Fixes implementiert**:
  - `alwaysUse24HourFormat: true` via MediaQuery.copyWith() im showTimePicker builder
  - Auto-save default times beim ersten Toggle (06:30, 13:30, 19:00)
  - Debounce standardisiert auf 300ms (war 400ms) via DebounceConstants
- **Test-Infrastruktur**:
  - fake_cloud_firestore integration für Firebase mocking
  - 27/27 Tests passing (war 16/27 vor Bugfix)

### UX/Performance: Textfeld Debounce Standardisierung (#116)
- **Problem gelöst**: Unterschiedliche Debounce-Zeiten führten zu inkonsistentem Feedback
- **DebounceConstants eingeführt**:
  - `textFieldDebounce: Duration(milliseconds: 300)` - Standard für alle Textfelder
  - `instantFeedback: Duration.zero` - Checkboxen, Buttons, Ratings
- **Angewendet auf**: DaySyncLogic, MealTrackerCard, Planning TextFields
- Konsistentes User-Feedback app-wide

### Infrastructure: CI/CD & Test Coverage Improvements
- **Coverage Badges**: Codecov + Tests Badges zu README.md hinzugefügt
- **Release Workflow erweitert**:
  - Web build artifacts mit retention (90 Tage)
  - CHANGELOG.md auto-update aus Git commits
  - Release notes generation mit artifact links
- **CI/CD Dokumentation**:
  - `docs/CI_CD_IMPROVEMENTS.md` mit vollständigem Status & Roadmap
  - Prioritisierte Action Items (Firebase Emulator, 50% Coverage, Golden Tests)
  - Issue management Prozess dokumentiert
- **Neue fokussierte Issues**:
  - #120: Firebase Emulator Integration Tests
  - #121: 50% Test Coverage Target
  - #122: Golden Tests für UI Regression Prevention

### Feature: Custom Habit Order mit festen Kategorienfarben (#91)
- **Problem gelöst**: User konnten Habit-Reihenfolge nicht anpassen, Farben waren inkonsistent
- **Fixed Category Colors**:
  - CategoryColors utility mit 10 festen Kategorie→Farbe Mappings
  - 🔥 GESUNDHEIT: #34C759, 🚴 SPORT: #FF3B30, 📘 LERNEN: #0A84FF
  - HabitCard verwendet Kategorienfarbe statt habit.color
  - HabitDialog zeigt automatisch zugewiesene Farbe (kein manueller Picker mehr)
- **Drag & Drop Reordering**:
  - "Reihenfolge ändern" Button pro Kategorie in HabitScreen
  - ReorderableListView Dialog für intuitive Sortierung
  - Batch Firestore Update (reorderHabits) statt einzelner Schreibvorgänge
  - sortIndex in 10er-Schritten vergeben (0, 10, 20, ...) für zukünftige Flexibilität
- **Smart Sorting**:
  - sortHabitsByCustomOrder(): Unerledigte Habits nach sortIndex, erledigte ans Ende
  - Auto-assign sortIndex bei Habit-Erstellung (max + 10)
  - Fallback auf createdAt bei fehlendem sortIndex
- **Service-Erweiterungen**:
  - reorderHabits(): Batch-Update für mehrere Habits
  - getMaxSortIndex(): Ermittelt höchsten sortIndex für neue Habits
  - sortHabitsByCustomOrder(): Sortiert nach Custom Order + Completion Status

### Geschlossene Issues
- #115: Tab-Navigation springt bei Desktop-Nutzung
- #118: Uhrzeitauswahl im Essen-Tracker zeigt AM/PM statt 24h-Format
- #116: Textfelder speichern Eingaben unterschiedlich schnell
- #114: Cards für Essen und Tagesbilanz müssen klappbar werden
- #91: Individuelle Habit-Sortierung (Custom Order) bei fixen Kategorienfarben

### Issue Management & Cleanup
- ✅ #102 als Duplicate von #107 markiert und dokumentiert
- ✅ #103 und #107 Status-Updates mit Links zu neuen Test-Issues
- ✅ #109 und #101 (Weekly Review) verschoben nach v1.7.0 Milestone
- ✅ Neue Test-Issues erstellt: #120 (Firebase), #121 (Coverage), #122 (Golden Tests)

## v1.6.1 (2025-11-18) - Collapsible Cards (SUPERSEDED - merged into main v1.6.1)

### UX/Bug: Collapsible Cards für Essen und Tagesbilanz (#114)
- **Problem gelöst**: HabitInsightsCard und MealTrackerCard blockierten auf mobilen Geräten fast den gesamten Screen
- **ReflectoCard Widget erweitert**:
  - `isCollapsible` Parameter aktiviert Collapse-Funktion
  - IconButton mit AnimatedRotation (0° → 180°, 200ms ease)
  - SizeTransition mit Curves.easeInOut für smooth Animation
  - Tooltip: "Aufklappen" / "Einklappen"
- **State Management mit SharedPreferences**:
  - Neue Providers: `habitInsightsCardCollapseProvider`, `mealTrackerCardCollapseProvider`
  - Persistierung: User-Präferenz bleibt nach App-Neustart erhalten
  - Adaptive Defaults: Mobile (<600px) eingeklappt, Tablet/Desktop ausgeklappt
- **UI Updates**:
  - HabitInsightsCard: Titel "📊 Habit-Insights" + Collapse-Toggle
  - MealTrackerCard: Titel "🍽️ Essen" + Collapse-Toggle
- **Akzeptanzkriterien erfüllt**:
  - ✅ Habits auf kleinen Screens lesbar
  - ✅ Cards lassen sich einwandfrei auf- und zuklappen
  - ✅ Layout springt nicht (SizeTransition mit axisAlignment: -1.0)
  - ✅ Keine Performance-Einbußen (SingleTickerProviderStateMixin)

### Geschlossene Issues
- #114: UX/Bug - Cards für Essen und Tagesbilanz müssen klappbar werden

---

## v1.6.0 (2025-11-17) - Productivity MVP

### Habit-Insights (Mini-Analytics) (#92)
- **Tagesbilanz**: X von Y erledigte Habits mit Momentum-Indikator ⭐ bei ≥80% Completion
- **Kategorie-Progress**: Farbige Fortschrittsbalken pro Kategorie mit Completion-Werten (z.B. 3/5)
- **Trendkarte**: Top 3 Habits mit höchsten Streaks und Trend-Icons (▲ steigend ≥7 Tage, ● stabil ≥3 Tage, ▼ fallend <3 Tage)
- **Spotlight**: Fokus-Empfehlung für schwächste Kategorie oder Celebration bei ≥80% in allen Kategorien
- Client-side Berechnung (kein Firestore Write), automatisches Ausblenden bei 0 Habits
- ReflectoCard Widget für konsistentes Styling

### Smart Habits Auto-Priorisierung (#93)
- **Score-Model (0-100 Punkte)**:
  - Streak-Komponente (0-30): Längere Streaks = höhere Priorität
  - Konsistenz letzte 7 Tage (0-40): Hohe Completion-Rate
  - Skip-Analyse (0-30): Geplante aber nicht erledigte Tage
- **Priority Levels**:
  - 🔥 High: ≥70 Punkte (starkes Momentum, konsistent)
  - ⬆️ Medium: ≥40 Punkte (stabil, gelegentliche Lücken)
  - ⬇️ Low: <40 Punkte (inkonsistent, viele Skips)
- **UI**: Smart Priority FilterChip Toggle, Priority Badges auf HabitCards, Auto-Sort nach Score
- HabitPriority enum mit Icon/Label Extensions
- calculateHabitPriority() und sortHabitsByPriority() in HabitService

### Zeitauswahl bei Mahlzeiten (#112)
- **breakfastTime, lunchTime, dinnerTime** Felder im MealLog Model (HH:mm format)
- **Intelligente Standardzeiten**:
  - Wochentage: Frühstück 06:30, Mittag 13:30, Abend 19:00
  - Wochenende: Frühstück 09:00, Mittag 14:00, Abend 19:00
- TimePicker Button (🕐 Icon + Zeit) neben jedem Mahlzeiten-Textfeld
- showTimePicker Dialog zum Anpassen
- Sofortige Firestore-Speicherung
- _getDefaultTime() berechnet Defaults basierend auf Mahlzeit-Typ & Wochentag

### Geschlossene Issues
- #92: Habit-Insights (Mini-Analytics)
- #93: Smart Habits – Auto-Priorisierung
- #112: Zeitauswahl bei Mahlzeiten-Eingabe

### Geschlossene Milestones
- ✅ v1.6.0 (Productivity MVP) - 3/5 Features

### Offene Issues für v1.6.0
- #91: Custom Habit Sorting (Drag & Drop)
- #101/#109: Weekly Review (Snapshot + Display)

## v1.5.1 (2025-11-17)

### Dokumentation
- **ARCHITECTURE.md**: Umfassende Überarbeitung mit Riverpod-Patterns, Services, UI-Layer-Struktur, 50% Test-Coverage-Target
- **DATA_MODEL.md**: Aktualisiert mit habits, meals, weeklyReflections; Future Collections (weeklyStats, userSettings) dokumentiert
- **LABELS.md**: GitHub Label-Standards für Issues/PRs (Typ, Bereich, Status, Best Practices)
- **ROADMAP.md**: Milestone-basierte Roadmap (v1.5.0 → v2.0.0) statt Phase-Modell

### Tests
- **habit_service_test.dart**: 40+ Test-Cases für HabitService
  - Streak-Berechnung (aufeinanderfolgende Tage, Lücken, Edge Cases)
  - Scheduling-Logik (daily, weekly_days, weekly_target, irregular)
  - Wöchentliche Completion-Zählung
  - Geplante Tage pro Woche
  - Completion-Status-Checks

### Geschlossene Issues
- #103: Tests – Kernlogik (Streaks, Sorting, Week)
- #105: Documentation – Firestore Schema
- #106: Repo Standards – Templates + Cleanup
- #108: Dokumentation – ARCHITECTURE.md

### Geschlossene Milestones
- ✅ v1.4.0 (Habit Tracker)
- ✅ v1.4.1 (Follow-ups)
- ✅ v1.5.0 (KI-Auswertung, Documentation)

### Dependencies
- chore(deps): bump http from 1.5.0 to 1.6.0 (#90)

## v1.4.0 (2025-11-16)

### Habit Tracker (#57)
- **Kernfunktionen**:
  - Gewohnheiten erstellen/bearbeiten/löschen mit Titel, Kategorie, Farbe
  - Flexible Frequenzen: Täglich, Wochentage (Mo-So auswählbar), Wochen-Ziel (z.B. 3×/Woche), Unregelmäßig
  - Streak-Tracking (nur für tägliche Habits)
  - Wöchentlicher Fortschritt mit Live-Anzeige (X/Y erfüllt)
  - Toggle-Checkboxen nur an geplanten Tagen aktiv
  - Weekday-Pills zeigen aktive Wochentage
- **UI/UX**:
  - Habit-Screen mit Fortschritts-Header (Heute: X/Y erfüllt, Prozentanzeige)
  - "Nur fällige" Filter-Toggle für fokussierte Ansicht
  - Gruppierung nach Kategorien mit fester Reihenfolge (8 Haupt-Kategorien mit Emojis)
  - Reorder-Dialog pro Kategorie für benutzerdefinierte Sortierung (sortIndex)
- **Vorlagen-System**:
  - 40+ kuratierte Habit-Templates in 8 Kategorien (Gesundheit, Sport, Lernen, Kreativität, Produktivität, Soziales, Achtsamkeit, Sonstiges)
  - Server-seitige Templates in Firestore (`habit_templates` Collection)
  - Bottom-Sheet zur Vorlagen-Auswahl beim Erstellen neuer Habits
  - Seeding-Funktion für Admins (Debug-Mode oder UID-Allowlist)
  - Timeout-Fallback (3s) für Template-Loading
- **Migration & Admin-Tools**:
  - Kategorie-Migration für Upgrade auf Emoji-Kategorien
  - Admin-Icons in AppBar für Template-Seeding und Migration (nur Debug/Admin)
- **Datenmodell**:
  - `users/{uid}/habits`: Habit-Dokumente mit frequency, weekdays, weeklyTarget, sortIndex, streak, completedDates
  - `habit_templates`: Globale Vorlagen-Collection

### Meal Tracker
- **Tages-Essenslog**:
  - Frühstück/Mittag/Abend Toggle-Chips
  - Pro Mahlzeit kurze Gericht-Notiz (TextField mit 400ms Debounce)
  - Fortschrittsbalken (X/3 erfasst)
  - Integration im Day-Screen nach der Morgen-Sektion
- **Datenmodell**:
  - `users/{uid}/meals/{yyyy-MM-dd}`: Dokumente mit breakfast, lunch, dinner (bool) und breakfastNote, lunchNote, dinnerNote (optional)
  - Automatische Dok-Erstellung beim ersten Toggle/Notiz
- **Persistenz**:
  - Optimistische Updates mit Focus-Guard (kein Überschreiben während Eingabe)
  - Merge-Writes für Partial-Updates

### Technische Verbesserungen
- **Habit-Service**: Scheduling-Logik (isScheduledOnDate, getWeekWindow), Wochen-Counter (countCompletionsInWeek, plannedDaysInWeek)
- **Providers**: Habit-Notifier für CRUD, Template-Stream, Meal-Notifier für Toggle/Notes
- **UI-Komponenten**: HabitCard, HabitDialog (4-Mode-Segmentation), MealTrackerCard (stateful mit Controllern)
- **Migration-Service**: Batch-Update für Kategorie-Upgrade (alte → Emoji-Versionen)

### Validierung
- `flutter analyze`: Keine Befunde
- Unit-Tests: Alle bestanden
- Firestore-Schema: Neue Collections `habits`, `habit_templates`, `meals/{date}`

## v1.3.1 (2025-11-16)

### Datenmodell & Performance (#52)
- **Typisierte Firestore-Zugriffe**: Entries, Users und WeeklyReflections nutzen `.withConverter<T>` für type-safe Streams/Fetches
- **Timestamps**: `createdAt` bei Tages-Erstanlage; `updatedAt` konsequent via `serverTimestamp()`
- **Atomare Transaktionen**: Streak-Update (Abendabschluss + Zähler) in einer Transaction — eliminiert Race Conditions
- **Batch-Writes**: Maintenance-Dedupe nutzt Batches (max 450 Ops/Commit) statt Einzel-Writes — deutlich performanter
- **WeeklyReflection-Model**: Neue typisierte Klasse mit Unit-Test; saubere Trennung von Lese-/Schreiblogik
- **Doku**: `DATA_MODEL.md` aktualisiert mit allen Schema-Änderungen

### UI & Design-Konsistenz (#53)
- **Spacing-Tokens**: Flächendeckende Nutzung von `ReflectoSpacing` (s4/s8/s12/s16/s24) statt Magic Numbers
- **Theme-TextStyles**: Titel/Labels über `Theme.of(context).textTheme.*` statt Inline-Styles
- **Aktualisierte Komponenten**:
  - Screens: `AuthScreen`, `SettingsScreen`, `WeekScreen`, `HomeScreen`
  - Settings-Widgets: `VersionInfo`, `ProfileSection`
  - Week-Widgets: `WeekStatsCard`, `WeekNavigationBar`, `WeekExportCard`, `WeekAiAnalysisCard`
  - Day-Widgets: `EmojiBar`, `LabeledField`, `DayStreakWidget`, `DayShell`, `EveningSection`
- **STYLEGUIDE**: Präzisiert mit Hinweisen zu Tokens/Theme-Nutzung

### Riverpod-Optimierung (#51)
- Provider mit dynamischen Parametern (`.family`) nutzen jetzt `autoDispose`
- Automatische Bereinigung von `weekEntriesProvider`, `weeklyReflectionProvider`, `dayEntryProvider`, `dayDocProvider`
- Reduzierter Speicherverbrauch bei Navigation zwischen Tagen/Wochen

### Dependencies
- `package_info_plus`: 8.3.1 → 9.0.0

### Validierung
- `flutter analyze`: Keine Befunde
- Unit-Tests: Erweitert (WeeklyReflection-Model)
- Rückwärtskompatibel: Schema/Felder unverändert; reine App-seitige Typisierung

## v1.3.0

- Move: Transaktionsbasierte Logik mit Dedupe (keine Duplikate; leere Slots werden bevorzugt befüllt), Undo in der UI.
- Wartung: Einstellungen → „Planung deduplizieren“ (einmalig pro Nutzer ausführen).
- Stabilität: Mounted‑Checks vor Snackbars; bereinigte Context‑Verwendung.
- Vorbereitung: Grundlage für selektivere Rebuilds (Riverpod).

## v1.2.3

- DayScreen: Kompaktere Ansicht (Karussell fix oben, AppBar entfernt).
- Streak: Als Card unter Planung, mit Feuer‑Icon; doppelte Anzeige entfernt.
- Status: Sofortiges Pending (optimistic) + Heute‑Metadaten; Chip reagiert schneller.
- UI‑Polish: Daypicker neben Karussell, Header‑Abstände reduziert.
- Style: Token‑Layer (Farben/Spacing/Radii/Breakpoints/Motion) + STYLEGUIDE.
- CI: Flutter‑CI für PRs auf dev aktiviert.

## v1.2.2

- Fix: Doppelte Streak‑Anzeige — Streak im DayScreen entfernt; Anzeige zentral im HomeScreen (fixes #49).
- Feature: Auto‑Streak — Abendabschluss automatisch, sobald mind. 1 Ziel und 1 To‑do erledigt sind; Button entfernt.

## v1.2.1

- Streak‑System
  - Riverpod `streakInfoProvider` + Anzeige in Home/Day
  - Service `markEveningCompletedAndUpdateStreak` pflegt `longestStreak`
  - Snackbar beim Abendabschluss und Fix für 1‑Tag‑Reset (Issue #18)
- Tagesansicht
  - AppBar‑Titel vereinfacht; Datum über die Chips
  - Streak‑Zeile im DayScreen entfernt (zentral im HomeScreen)
- Cleanup
  - Konfliktmarker entfernt, ungenutzte Helper/Imports bereinigt
  - Locale‑Init (`intl`) abgesichert

## v1.2.0

- UI/Tagesansicht
  - Deutsches Datumsformat (AppBar) mit `intl`
  - Kalender‑Bottom‑Sheet zur Datumsauswahl
  - 7‑Tage‑Leiste (ChoiceChips) + Swipe‑Navigation (±1 Tag)
  - Heutiger Tag hervorgehoben (Punkt/Umrandung)
  - Streak‑Kontextzeile: „🔥 X Tage in Folge“
- Settings
  - Unbenutzte Sign‑Out‑Methode/Import entfernt
- Build
  - Vereinheitlichte Version/Build‑Quelle (Fix #16)

## v1.1.0

- Einstellungen
  - Theme‑Umschaltung: System/Hell/Dunkel, persistent
  - Profil bearbeiten (FirebaseAuth + Firestore)
  - Versionsanzeige im Einstellungen‑Reiter
- UI/Lesbarkeit
  - Status‑ und Fortschritts‑Chips auf ColorScheme
  - Emoji‑Ratings mit Theme‑Farben
- CI/Automation
  - Flutter CI (Format/Analyze/Test, Web‑Build)
  - GitHub Pages nur auf `main`, PWA/SW aus
  - PR‑Checks: Semantic PR, Auto‑Labels, PR‑Templates
  - Dependabot: Auto‑Merge Minor/Patch
- Tests/Fixes
  - Widget‑Smoketest unabhängig von Firebase
  - Analyzer‑Warnungen/Deprecations bereinigt

