---
name: GitHub Checks Improvement
about: Überarbeitung der GitHub CI/CD Workflows
title: 'Überarbeitung der GitHub Checks und CI/CD Workflows'
labels: enhancement, ci/cd
assignees: ''
---

## Beschreibung

Die GitHub Checks und CI/CD Workflows müssen überarbeitet und modernisiert werden, um eine bessere Code-Qualität und automatisierte Tests zu gewährleisten.

## Ziele

- [ ] GitHub Actions Workflows für automatische Tests einrichten
- [ ] Flutter Analyze in CI/CD Pipeline integrieren
- [ ] Automatische Tests bei Pull Requests
- [ ] Code Coverage Reporting
- [ ] Linting und Formatting Checks automatisieren
- [ ] Build-Checks für Android/iOS/Web

## Vorgeschlagene Workflows

### 1. Lint & Format Check
- `flutter analyze` ausführen
- `dart format --set-exit-if-changed` prüfen
- Bei PR: Nur geänderte Dateien checken

### 2. Unit Tests
- `flutter test` ausführen
- Coverage Report generieren
- Mindest-Coverage Threshold definieren

### 3. Build Checks
- Android: `flutter build apk --debug`
- iOS: `flutter build ios --debug --no-codesign`
- Web: `flutter build web`

### 4. Dependency Updates
- Dependabot für Flutter/Dart Packages
- Automatische PR für Updates

## Priorität

Medium - Sollte vor dem nächsten größeren Release implementiert werden

## Zusätzliche Notizen

- Pre-commit Hook funktioniert lokal gut, aber GitHub Checks fehlen
-考虑到 Flutter 3.x Kompatibilität
- Workflow-Dateien in `.github/workflows/` erstellen
