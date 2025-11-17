# Changelog

Alle nennenswerten Änderungen an Reflecto.

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

