# Developer Quickstart Checklist

**Ziel:** Neuen Contributor in <15 Minuten setup-ready machen.

---

## ✅ Prerequisites

- [ ] **Flutter SDK:** 3.24.0+ (stable channel)
  ```bash
  flutter --version
  ```
- [ ] **Dart SDK:** 3.8.0+ (included in Flutter)
- [ ] **Git:** Version control
- [ ] **IDE:** VS Code (empfohlen) oder Android Studio
- [ ] **Node.js:** 18+ (für Firebase CLI/Emulator)

---

## 🚀 Initial Setup (5 Minuten)

### 1. Repository klonen
```bash
git clone https://github.com/AlexBuchnerTeacher/reflecto.git
cd reflecto
```

### 2. Dependencies installieren
```bash
flutter pub get
```

### 3. Firebase Emulator installieren (optional für lokale Tests)
```bash
npm install -g firebase-tools
firebase login
```

### 4. VS Code Extensions (empfohlen)
- Dart
- Flutter
- Firebase (for emulator)
- GitLens
- Flutter Coverage (lcov)

---

## 🔧 Entwicklungsumgebung

### Option A: Web-Entwicklung (schnellster Start)
```bash
flutter run -d chrome
```

**Test mit eigenem Chrome-Profil:**
```powershell
flutter run -d chrome `
  --web-browser-flag="--user-data-dir=C:\Users\YourName\AppData\Local\Google\Chrome\User Data" `
  --web-browser-flag="--profile-directory=Default"
```

### Option B: Android Emulator
```bash
flutter emulators --launch Pixel_7_API_34  # oder dein Emulator-Name
flutter run -d emulator-5554
```

### Option C: iOS Simulator (nur macOS)
```bash
open -a Simulator
flutter run -d "iPhone 15"
```

---

## 🔐 Secrets & Konfiguration

### Firebase Config (bereits im Repo)
- `lib/firebase_options.dart`: **KEINE Secrets!** (Web API Keys sind öffentlich)
- Firebase Rules schützen die Daten: `firestore.rules`

### Lokale Firebase-Entwicklung
```bash
firebase emulators:start --only firestore,auth
```

**Wichtig:** Emulator läuft auf `localhost:8080` (Firestore UI)

---

## 🧪 Tests ausführen

### Alle Tests
```bash
flutter test
```

### Mit Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
start coverage/html/index.html  # Windows
```

### Nur Unit Tests
```bash
flutter test test/unit/
```

### Formatting + Analyze
```bash
dart format .
flutter analyze
```

---

## 🔄 Workflow (Konventionen)

### Branch erstellen
```bash
git checkout -b feature/your-feature-name
git checkout -b fix/issue-123-description
```

### Commit Messages (Conventional Commits)
```
feat: add collapsible ReflectoCard
fix: resolve Firebase initialization in tests
docs: update TEST_STRATEGY.md
chore: bump dependencies
```

### Pre-Commit Checks (automatisch via Hook)
```bash
# Wird automatisch ausgeführt bei git commit
./scripts/pre-commit.sh
```

**Manuell installieren:**
```bash
cp scripts/pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Pull Request erstellen
1. Push branch: `git push origin feature/your-feature`
2. GitHub PR öffnen
3. CI läuft automatisch (lint, test, build)
4. Review abwarten
5. Merge via Squash & Merge

---

## 🐛 Troubleshooting

### Problem: `firebase_core` Fehler beim Test
**Lösung:**
```dart
// In test_helpers.dart
setupFirebaseAuthMocks();
await Firebase.initializeApp();
```

### Problem: `pubspec.yaml` dependency conflict
**Lösung:**
```bash
flutter pub upgrade
flutter pub outdated  # Check für Updates
```

### Problem: Web Build hängt
**Lösung:**
```bash
flutter clean
flutter pub get
flutter build web --release
```

### Problem: Android Build Fehler (Gradle)
**Lösung:**
```bash
cd android
./gradlew clean
cd ..
flutter build apk --debug
```

### Problem: Coverage-Report zeigt 0%
**Lösung:**
- Stelle sicher, dass Tests tatsächlich laufen: `flutter test -v`
- Check `coverage/lcov.info` existiert
- Installiere `lcov`: `choco install lcov` (Windows) oder `brew install lcov` (macOS)

---

## 📚 Wichtige Docs

- **Architektur:** `docs/ARCHITECTURE.md`
- **Datenmodell:** `docs/DATA_MODEL.md`
- **Roadmap:** `ROADMAP.md`
- **Contributing:** `CONTRIBUTING.md`
- **Maintainer Guide:** `docs/MAINTAINER_GUIDE.md`
- **Test Strategy:** `docs/TEST_STRATEGY.md`

---

## 🎯 Typische Entwicklungs-Tasks

### Neues Feature entwickeln
1. Issue erstellen/zuweisen
2. Branch: `feature/issue-123-description`
3. Tests schreiben (TDD wenn möglich)
4. Feature implementieren
5. `flutter analyze` und `flutter test` lokal
6. Commit + Push + PR
7. CI Review abwarten

### Bug fixen
1. Issue reproduzieren (lokal oder in Emulator)
2. Branch: `fix/issue-456-description`
3. Test schreiben, der Bug zeigt (rot)
4. Fix implementieren (grün)
5. Refactor (clean code)
6. PR erstellen

### Dokumentation aktualisieren
1. Datei ändern (z.B. `ARCHITECTURE.md`)
2. Commit: `docs: update architecture for v1.6.1`
3. Push + PR (auch für Docs!)

---

## 🚦 CI/CD Pipeline

- **Lint & Format:** `.github/workflows/lint.yml`
- **Tests:** `.github/workflows/test.yml` (mit Coverage)
- **Build:** `.github/workflows/build.yml` (APK + iOS)
- **Deploy:** `.github/workflows/gh-pages.yml` (Web → GitHub Pages)

**Status Badges:** Siehe `README.md`

---

## 🔥 Schnell-Befehle (Cheat Sheet)

```bash
# Dev Server starten
flutter run -d chrome

# Hot Reload
r (in laufendem flutter run)

# Tests mit Watch Mode (via IDE)
Flutter: Run Tests (VS Code Command Palette)

# Rebuild clean
flutter clean && flutter pub get && flutter run

# Firebase Emulator + App parallel
firebase emulators:start &
flutter run -d chrome

# Coverage HTML Report
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html && start coverage/html/index.html
```

---

## 📞 Support

- **Issues:** https://github.com/AlexBuchnerTeacher/reflecto/issues
- **Discussions:** GitHub Discussions Tab
- **Maintainer:** @AlexBuchnerTeacher

---

**Happy Coding! 🚀**
