# Changelog

Alle nennenswerten Änderungen an Reflecto.

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

