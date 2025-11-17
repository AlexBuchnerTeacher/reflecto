# Reflecto

[![Flutter CI](https://github.com/AlexBuchnerTeacher/reflecto/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/AlexBuchnerTeacher/reflecto/actions/workflows/flutter-ci.yml)
[![Deploy Web](https://github.com/AlexBuchnerTeacher/reflecto/actions/workflows/gh-pages.yml/badge.svg)](https://github.com/AlexBuchnerTeacher/reflecto/actions/workflows/gh-pages.yml)

Reflecto ist eine plattformübergreifende Flutter‑App (Web, Desktop, Mobile) für digitales Journaling und persönliche Entwicklung.

Kurz
- Flutter: Material 3, Google Fonts (Inter)
- State: Riverpod
- Backend: Firebase (Auth, Firestore)
- Features: Tagesplanung, Morgen‑Check‑in, Abendreflexion, Ratings, Wochenreflexion mit Export (JSON/Markdown) und Import der KI‑Auswertung

Schnellstart (lokal)

1. Voraussetzungen
   - Flutter (stable), z. B. Flutter 3.22+ (install unter https://flutter.dev)
   - Android Studio / Xcode für native Builds
   - Optional: Firebase CLI (für Emulatoren / Deploy)

2. Repository klonen
```bash
git clone https://github.com/AlexBuchnerTeacher/reflecto.git
cd reflecto
```

3. Abhängigkeiten installieren
```bash
flutter pub get
```

4. App starten
- Web (Chrome):
```bash
flutter run -d chrome
```
- Windows:
```bash
flutter run -d windows
```
- Android / iOS:
```bash
flutter run -d <device-id>
```

Tests
```bash
flutter test
# Coverage (optional)
flutter test --coverage
```

Analyse / Format
```bash
flutter analyze
flutter format .
```

Entwicklung & Architektur (Kurzüberblick)
- State-Management: Riverpod / AsyncNotifier (siehe lib/)
- Datenpersistenz: Firebase Firestore; Firestore-Regeln in firestore.rules
- Trennung: UI / Services / Providers — siehe lib/ für konkrete Ordnerstruktur

Firebase
- firebase_options.dart ist enthalten. Für Web: autorisierte Domains in Firebase Console prüfen.

Contributing
- Fork → Branch → PR
- Commit-Message: kurz + Issue-Nummer (z. B. `feat: add habit insights (#92)`)
- Schreibe Tests für Business-Logic bei größeren Änderungen.
- Siehe CONTRIBUTING.md für Details.

CI / Releases
- GitHub Actions: flutter analyze + tests + builds (vorgeschlagene Workflow: .github/workflows/flutter-ci.yml)
- CHANGELOG.md und RELEASE_NOTES_v*.md für Releases; Release-Automation kann ergänzt werden.

Security & License
- Lizenz: MIT (LICENSE im Repo)
- Keine Secrets / API-Keys im Repo: nutze GitHub Secrets

Nützliche Links
- Issues: https://github.com/AlexBuchnerTeacher/reflecto/issues
- Repo: https://github.com/AlexBuchnerTeacher/reflecto