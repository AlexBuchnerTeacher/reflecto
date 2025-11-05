# Reflecto

[![Flutter CI](https://github.com/AlexBuchnerTeacher/reflecto/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/AlexBuchnerTeacher/reflecto/actions/workflows/flutter-ci.yml)
[![Deploy Web](https://github.com/AlexBuchnerTeacher/reflecto/actions/workflows/gh-pages.yml/badge.svg)](https://github.com/AlexBuchnerTeacher/reflecto/actions/workflows/gh-pages.yml)

Reflecto ist eine plattformübergreifende Flutter‑App (Web + Windows) für digitales Journaling und persönliche Entwicklung.

- Flutter: Material 3, Google Fonts (Inter)
- State: Riverpod
- Backend: Firebase (Auth, Firestore)
- Features: Tagesplanung, Morgen‑Check‑in, Abendreflexion, Ratings, Wochenreflexion mit Export (JSON/Markdown) und Import der KI‑Auswertung

## Entwicklung

- Voraussetzungen: Flutter Stable 3.22+, Dart SDK passend zur Flutter‑Version
- Abhängigkeiten laden: `flutter pub get`
- Start Web: `flutter run -d chrome`
- Start Windows: `flutter run -d windows`

## Theme

Die zentralen Farben und Themes liegen in `lib/theme/reflecto_theme.dart` (Light/Dark, Material 3, konsistente Komponenten).

## Firebase

`firebase_options.dart` ist vorhanden und wird verwendet. Für Web bitte die autorisierten Domains in der Firebase Console pflegen.

## Git

- Standard `.gitignore` und `.gitattributes` sind enthalten (LF‑Zeilenenden für Quelltexte).

## Live

- GitHub Pages: https://alexbuchnerteacher.github.io/reflecto/
- Hinweis: Für Login auf Web muss die Domain `alexbuchnerteacher.github.io` in Firebase Auth → Authorized domains eingetragen sein.
