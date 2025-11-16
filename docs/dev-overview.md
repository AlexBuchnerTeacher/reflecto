# Reflecto – Entwickler-Überblick

Dieses Dokument richtet sich an Entwickler:innen, die in Reflecto einsteigen oder Features weiterbauen wollen.

## 1. Funktionaler Überblick

- Digitale Tagebuch-/Reflexions-App mit drei Phasen:
  - **Morgen**: Stimmung, Fokus, gute Dinge.
  - **Planung für morgen**: Ziele & To-Dos, Reflexion, Notizen.
  - **Abend**: Rückblick, Dankbarkeit, Learnings, Abhaken von Zielen/To-Dos.
- Backend:
  - Firebase Auth für Login.
  - Firestore für `users/{uid}/entries/{date}`-Einträge.
- Zusatz:
  - Streak-Logik (Tage in Folge).
  - Wochenansicht mit Export/Import.
  - Settings (Theme, Profil, Version).

## 2. Architektur & Konventionen

Zentrale Richtlinien liegen in `.reflecto/`:

- `coding_guidelines.md`
  - Single Responsibility pro Datei.
  - Trennung UI / Logic / Controller / Widgets.
  - Größenlimits (Widgets ~150 Zeilen, Logic ~300 Zeilen).
- `folder_structure.md`
  - Feature-basierte Struktur unter `lib/features/<feature>/`.
  - Services zentral unter `lib/services/`.
- `naming_conventions.md`
  - Dateiname = Klassenname (`<Feature><Name>Screen`, `Logic`, `Section`, `Widget`, `Controller`, `Provider`).
- `riverpod_rules.md`
  - Provider nicht im UI erstellen.
  - Provider nach Feature-Namespace organisieren.

## 3. Wichtige Ordner unter `lib/`

- `lib/main.dart`
  - App-Entry, Routing, Theme.
- `lib/screens/`
  - Thin-Screens / Entry Points:
    - `home_screen.dart`
    - `day_screen.dart` (exportiert das Day-Feature: `../features/day/ui/day_screen.dart`)
    - `week_screen.dart`
    - `settings_screen.dart`
    - `auth_screen.dart`
- `lib/features/`
  - Feature-Module, z. B. `lib/features/day/**` (siehe Abschnitt 4).
- `lib/services/`
  - Firestore- und Auth-Services:
    - `firestore_service.dart` (zentrale Firestore-Zugriffe).
    - `auth_service.dart`
    - `export_import_service.dart`
    - `google_signin_io.dart` / `google_signin_stub.dart`
- `lib/providers/`
  - Riverpod-Provider (Auth, Entries, Streak, Settings, …).
- `lib/widgets/`
  - Shared UI-Bausteine:
    - `reflecto_card.dart`, `reflecto_button.dart`, `reflecto_snackbar.dart`
    - `ratings_row.dart`, `reflecto_sparkline.dart`
- `lib/theme/`
  - Token-Layer (Color/Spacing/Radius/Breakpoints).

## 4. Day-Feature (`lib/features/day/**`)

Der Day-Bereich ist modularisiert und folgt den `.reflecto`-Guidelines.

- `day_header.dart`
  - Kopfbereich/Dashboard für den DayScreen (Datum, Streak, Status).

- `controllers/day_controllers.dart`
  - Hält alle `TextEditingController` und `FocusNode`s für:
    - Morgen (heute)
    - Planung (morgen)
    - Abend (heute)
  - Stellt `ensureGoalsLen/ensureTodosLen()` bereit.
  - Standard für Planung: 1 Ziel, 2 To-Dos.

- `logic/day_view_logic.dart`
  - Liest Firestore-Daten und bereitet sie für den View auf
    (Ratings, Listen etc., ohne `BuildContext`).

- `logic/day_sync_logic.dart`
  - Kapselt Firestore-Sync, Debounce, Caching und Update-Helper.

- `ui/day_screen.dart`
  - `ConsumerStatefulWidget`, orchestriert den Day-Flow:
    - Datumsauswahl, Expansionszustand (Morning/Planning/Evening).
    - Lesen von `dayDocProvider(_selected)` und `dayDocProvider(tomorrow)`.
    - Überträgt Snapshot-Werte in Controller (`_setCtrl`) unter Beachtung von Fokus.
    - Speichert Änderungen mit `_debouncedUpdate` / gezielten Helfern.
  - Planung (morgen):
    - Daten liegen als Arrays in `planning.goals` / `planning.todos`.
    - Leere Felder werden beim Speichern gefiltert.
    - Beim Laden werden Werte getrimmt, leere Einträge verworfen; mindestens 1 Ziel / 2 To-Dos werden als Felder angezeigt.
    - Reorder und Auto-Focus werden über Callbacks in `DayShellProps` gesteuert.
  - Abend-Review:
    - Checkbox-Listen für Ziele/To-Dos (gestern) basieren auf `goalsCompletion` / `todosCompletion`.
    - Lokaler Status (`_yesterdayGoalChecks`, `_yesterdayTodoChecks`) wird aus Firestore synchronisiert.

- `ui/day_shell.dart`
  - Reines Layout / Container:
    - Header, Streak-Widget, Week-Carousel, Swipe-Container.
    - Platzierung der Sections:
      - `MorningSection`
      - `PlanningSection`
      - `EveningSection`
  - `DayShellProps` als zentrales Props-Objekt mit Daten und Callbacks.

- `sections/morning_section.dart`
  - Widget für Morgen-Inputs (Gefühl, Gut heute, Fokus).

- `sections/planning_section.dart`
  - „Planung für morgen“:
    - Ziele & To-Dos als `ReorderableListView.builder` (shrinkWrap, ohne eigene Scrollbar).
    - Buttons „Neues Ziel“ / „Neues To-do“ (erzeugen neue Felder, Auto-Focus auf das neue Feld).
    - Entfernen:
      - Ziele nur, wenn mehr als 1 Ziel vorhanden.
      - To-Dos nur, wenn mehr als 2 To-Dos vorhanden.
      - Delete per Icon-Click und Long-Press.
    - Reflexion & Freies Notizfeld als `LabeledField`s.

- `sections/evening_section.dart`
  - Abend-Reflexion mit Textfeldern und Checkbox-Listen für Ziele/To-Dos.
  - Verwendet `goalChecks`, `todoChecks` und entsprechende Callbacks aus `DayShellProps`.
  - Bekannter Bug (Issue #73): Beim ersten Toggle einer Checkbox kann die gesamte Gruppe mit umschalten (wird in v1.3.1 adressiert).

- `widgets/` (Day-spezifisch)
  - `day_streak_widget.dart`: Streak-Anzeige.
  - `day_week_carousel.dart`: Datumsauswahl über horizontales Karussell.
  - `day_swipe_container.dart`: Swipe-Navigation (Tag vor/zurück).
  - `emoji_bar.dart`: Emoji-Ratings.
  - `labeled_field.dart`: Kleinere Wrapper um Textfelder mit Label.

## 5. Datenmodell & Firestore

Ein Tages-Eintrag liegt unter:

```text
users/{uid}/entries/{date}
```

Struktur (vereinfacht):

- `morning`:
  - Texte (z. B. `mood`, `goodThing`, `focus`) und Ratings.
- `evening`:
  - Texte (`good`, `learned`, `better`, `gratitude`) und Ratings.
  - `goalsCompletion`: Liste/Map von bools.
  - `todosCompletion`: Liste/Map von bools.
- `planning`:
  - `goals`: `List<String>`
  - `todos`: `List<String>`
  - `reflection`: `String?`
  - `notes`: `String?`

**Wichtig für Planung:**

- Speichern: `_saveGoals` / `_saveTodos` nehmen nur nicht-leere Strings auf.
- Laden: Strings werden via `toString().trim()` verarbeitet, leere Einträge ignoriert.
- UI zeigt immer mindestens 1 Ziel und 2 To-Dos (kann nach oben wachsen).

## 6. State-Management (Riverpod)

- Provider leben typischerweise in `lib/providers/` (außer Feature-spezifische Provider).
- Wichtige Provider:
  - `dayDocProvider(date)`: liest das Tages-Document aus Firestore.
  - `updateDayFieldProvider`: liefert eine Funktion, um ein Feld im Tages-Dokument zu aktualisieren.
  - Auth-, Streak- und Settings-Provider in den jeweiligen Dateien.
- Regeln (siehe `.reflecto/riverpod_rules.md`):
  - Provider nicht im UI erstellen (nur konsumieren).
  - StateNotifier/Logic vom UI entkoppeln.

## 7. Build, Tests & CI

- Lokale Entwicklung:
  - `flutter pub get`
  - `flutter run`
  - Vor Commits:
    - Pre-Commit-Hooks führen `dart format` aus.
    - Empfohlen: `flutter analyze`, `flutter test`.

- CI (`.github/workflows/flutter-ci.yml`):
  - `flutter pub get`
  - `dart format --output=none --set-exit-if-changed .`
  - `flutter analyze --fatal-infos`
  - `flutter test --no-pub --coverage`
  - `flutter build web --release --base-href /reflecto/`

- Release-Prozess (vereinfacht):
  - Feature-/Bugfix-PRs auf Branches.
  - Merge in `main` via PR, Checks müssen grün sein.
  - `pubspec.yaml: version` anpassen.
  - `CHANGELOG.md` ergänzen.
  - Tag `vX.Y.Z` setzen und pushen.
  - GitHub-Release anlegen (optional).

## 8. Milestones & offene Arbeiten

- `v1.3.0`:
  - Day-Feature-Modularisierung.
  - Dynamische Planung (Goals & To-Dos, fixes #58).
  - Stabilitätsverbesserungen laut `CHANGELOG.md`.
- `v1.3.1`:
  - Bugfixes & Follow-ups (z. B. Checkbox-Bug #73, Services-Review #69, Day-Refactor #70, Screens-Refactor #71).
- `v1.4.0`:
  - User-Features (Habits, Notifications).
- `v1.5.0`:
  - Analyse & Export (KI / Wochenanalyse).

## 9. Start für neue Entwickler:innen

Empfohlene Reihenfolge:

1. `main` auschecken, `flutter run`, kurz durch die App klicken (Home, Day, Week, Settings).
2. `.reflecto/`-Guidelines lesen (Coding, Naming, Struktur, Riverpod).
3. Day-Feature verstehen:
   - Einstieg: `lib/features/day/ui/day_screen.dart` + `day_shell.dart`.
   - Sections: `morning_section.dart`, `planning_section.dart`, `evening_section.dart`.
4. Erste Aufgaben über GitHub-Issues (Milestone `v1.3.1`) picken.

Bei neuen Features:

- Neuen Feature-Ordner unter `lib/features/<name>/` anlegen.
- UI in eigene `ui/`/`sections/`/`widgets/`-Dateien, Logik nach `logic/`, Controller in `controllers/`.
- Firestore-Zugriffe über Services/Provider abstrahieren, nicht direkt im Widget.

