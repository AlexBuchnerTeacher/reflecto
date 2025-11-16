# Changelog

Alle nennenswerten Änderungen an Reflecto.

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

