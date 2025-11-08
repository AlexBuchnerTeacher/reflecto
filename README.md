# Reflecto

[![Flutter CI](https://github.com/AlexBuchnerTeacher/reflecto/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/AlexBuchnerTeacher/reflecto/actions/workflows/flutter-ci.yml)
[![Deploy Web](https://github.com/AlexBuchnerTeacher/reflecto/actions/workflows/gh-pages.yml/badge.svg)](https://github.com/AlexBuchnerTeacher/reflecto/actions/workflows/gh-pages.yml)

Reflecto ist eine plattformÃ¼bergreifende Flutterâ€‘App (Web + Windows) fÃ¼r digitales Journaling und persÃ¶nliche Entwicklung.

- Flutter: Material 3, Google Fonts (Inter)
- State: Riverpod
- Backend: Firebase (Auth, Firestore)
- Features: Tagesplanung, Morgenâ€‘Checkâ€‘in, Abendreflexion, Ratings, Wochenreflexion mit Export (JSON/Markdown) und Import der KIâ€‘Auswertung

## Entwicklung

- Voraussetzungen: Flutter Stable 3.22+, Dart SDK passend zur Flutterâ€‘Version
- AbhÃ¤ngigkeiten laden: `flutter pub get`
- Start Web: `flutter run -d chrome`
- Start Windows: `flutter run -d windows`

## Theme

Die zentralen Farben und Themes liegen in `lib/theme/reflecto_theme.dart` (Light/Dark, Material 3, konsistente Komponenten).

## Firebase

`firebase_options.dart` ist vorhanden und wird verwendet. FÃ¼r Web bitte die autorisierten Domains in der Firebase Console pflegen.

## Git

- Standard `.gitignore` und `.gitattributes` sind enthalten (LFâ€‘Zeilenenden fÃ¼r Quelltexte).

## Live

- GitHub Pages: https://alexbuchnerteacher.github.io/reflecto/
- Hinweis: FÃ¼r Login auf Web muss die Domain `alexbuchnerteacher.github.io` in Firebase Auth â†’ Authorized domains eingetragen sein.
## Beitragen & Workflow

Bitte vor PRs den Beitragsleitfaden lesen:

- CONTRIBUTING.md

Kernpunkte:
- Über Feature-/Fix-Branches arbeiten; keine Direkt-Commits auf `main`.
- Kleine, fokussierte PRs; CI (analyze/lint/tests) muss grün sein.
- Conventional Commits mit Emojis (siehe Tabelle in CONTRIBUTING.md).
