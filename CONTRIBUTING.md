# Contributing & Reflecto Git Workflow

Dieses Dokument beschreibt den vereinbarten Arbeitsablauf (Branches, Commits, PRs, Releases) für dieses Repository. Bitte halte dich bei jeder Änderung daran.

## Reflecto Git Workflow

- Arbeit immer über Feature-/Fix-Branches, niemals direkt auf `main`.
- Kleine, fokussierte PRs mit kurzer Begründung und, wo sinnvoll, Screenshot/GIF.
- CI (Analyze/Lint/Build/Tests) muss grün sein, bevor gemerged wird.

## Branch-Struktur

| Branch           | Zweck                            | Besonderheit                              |
| ---------------- | -------------------------------- | ----------------------------------------- |
| `main`           | stabile Version, produktionsreif | keine direkten Commits (geschützt)        |
| `dev`            | aktive Entwicklung               | Feature-/Fix-Branches werden hier gemerged |
| `feature/<name>` | neue Features/Module             | z. B. `feature/streak_counter`            |
| `fix/<name>`     | Bugfixes                         | z. B. `fix/firestore_sync`                |
| `chore/<name>`   | Wartung/CI/Infra                 | z. B. `chore/gh_actions_pages`            |
| `docs/<name>`    | Dokumentation                    | optional                                  |
| `test/<name>`    | experimentelle Ideen             | optional                                  |

Hinweise:
- Branch-Namen nur Kleinbuchstaben, Trennzeichen `_` oder `-`.
- Falls `dev` (noch) nicht existiert, kann initial direkt nach `main` gemerged werden; anschließend bitte `dev` als Standard-Integrationszweig etablieren.

## Commit-Regeln

Conventional Commits erlaubt – ergänzt um Emojis. Subjekt im Imperativ, kurz (~50–72 Zeichen), optionaler Scope in Klammern.

| Kategorie        | Emoji | Beispiel                                                     |
| ---------------- | ----- | ------------------------------------------------------------ |
| Feature          | `✨`   | `✨ feat(streak): Add Streak Counter mit SharedPrefs`        |
| Fix              | `🐛`   | `🐛 fix(day): Fix NullCheck in DayScreen`                    |
| Config/Chore     | `🔧`   | `🔧 chore(rules): Update Firestore Security Rules`           |
| Refactor         | `♻️`   | `♻️ refactor(ui): Struktur von Widgets vereinfacht`          |
| Docs             | `📝`   | `📝 docs(readme): Ergänze Setup-Anleitung`                   |
| Release/Deploy   | `🚀`   | `🚀 release: v1.2.0`                                         |

Weitere Regeln:
- Eine Änderung pro Commit (so weit sinnvoll).
- Commit-Body für „Warum“/Kontext nutzen; referenziere Issues: `fixes #23`.

## Best Practices

- Kein direkter Push auf `main`.
- PRs dokumentieren (Kurzbeschreibung, ggf. Screenshot/Video, Testhinweis).
- Issue-Nummern in Commits/PR beschreiben (z. B. `fixes #123`).
- Releases taggen nach SemVer (`v1.0.0`, `v1.1.0`, …) und `CHANGELOG.md` pflegen.
- Automatische Checks über GitHub Actions: Flutter-Build, Analyze/Lint, Tests.

## GitHub Pages

- `gh-pages` dient als Veröffentlichungsquelle für die Flutter-Web-Builds.
- Der Deploy-Workflow überschreibt `gh-pages` bei jedem Release/Deploy.
- Optional (empfohlen): Deploys nur bei Tags/Releases ausführen.

## Empfohlene GitHub Actions

| Zweck              | Datei                           | Trigger             |
| ------------------ | ------------------------------- | ------------------- |
| Flutter CI Build   | `.github/workflows/flutter.yml` | `on: pull_request`  |
| Linter & Analyzer  | `.github/workflows/analyze.yml` | `on: push`          |
| Version Tagging    | `.github/workflows/release.yml` | `on: push -> main`  |

Hinweise:
- Für Releases: Version in `pubspec.yaml` erhöhen, `CHANGELOG.md` aktualisieren, Tag setzen (z. B. via `release.yml`).
- Pages-Deploys: nur aus geprüften Artefakten (CI-Build), nicht manuell.

## PR-Checkliste

- [ ] Branch-Name gemäß Konvention
- [ ] Commit-Nachrichten gemäß Regeln
- [ ] `flutter analyze` sauber
- [ ] Relevante Tests hinzugefügt/geprüft (falls sinnvoll)
- [ ] `CHANGELOG.md` aktualisiert (bei user-sichtbaren Änderungen)
- [ ] Screenshots/GIFs bei UI-Änderungen

## Entscheidungsregeln (kurz)

- „Klein und oft“: kleine PRs mergen, Folge-PRs statt Monster-PRs.
- Konflikte: lieber Rebase (linear) als Merge, sofern Review-Kontext erhalten bleibt.
- Schutzregeln: `main` geschützt; Rebase/Squash für Feature-PRs bevorzugt.

---

Fragen/Änderungen am Prozess bitte per Issue/PR vorschlagen.

## Commit-Template aktivieren

Dieses Repository bringt eine Commit-Vorlage mit (Conventional + Emoji): `.github/commit_template.txt`.

- Aktivierung (Repo-lokal):
  - `git config commit.template .github/commit_template.txt`
- Optional (global für alle Repos):
  - `git config --global commit.template ~/.git-commit-template.txt`
  - Datei kopieren: `cp .github/commit_template.txt ~/.git-commit-template.txt`

Hinweise:
- Pre-commit-Hooks können Formatierungen anpassen und einen erneuten Commit verlangen.
- VS Code: Der integrierte Git-Editor öffnet die Vorlage beim Commit automatisch.

## Mobile Builds: Version/Build (Issue #16)

Ziel: Einheitliche Quelle und Anzeige für Version und Buildnummer.

- Quelle Version: `pubspec.yaml: version` (SemVer, z. B. `1.2.3+45`).
- Settings zeigt:
  - Version: `PackageInfo.version` (SemVer, ohne Build-Anteil)
  - Build: `<buildNumber> <channel> <sha> <time>`

Beim mobilen Build (lokal/CI) bitte IMMER Name/Nummer setzen:

- Android:
  - `flutter build apk --release --build-name $Env:VERSION --build-number $Env:BUILD_NUMBER \
     --dart-define=BUILD_CHANNEL=$Env:BUILD_CHANNEL --dart-define=GIT_SHA=$Env:GIT_SHA --dart-define=BUILD_TIME=$Env:BUILD_TIME`
- iOS (Signatur/Provisioning erforderlich):
  - `flutter build ipa --release --build-name $VERSION --build-number $BUILD_NUMBER \
     --dart-define=BUILD_CHANNEL=$BUILD_CHANNEL --dart-define=GIT_SHA=$GIT_SHA --dart-define=BUILD_TIME=$BUILD_TIME`

Hinweise:
- `BUILD_CHANNEL` z. B. `dev`, `main`, `beta` (Default lokal: `local`).
- `GIT_SHA` bevorzugt der Commit SHA, `BUILD_TIME` ISO-Zeitstempel (z. B. CI-Startzeit).
- Web-Build (Pages) setzt die `--dart-define` bereits im Workflow.

Beispiel (lokal, PowerShell):

```
$Env:VERSION = '1.0.1'
$Env:BUILD_NUMBER = '12'
$Env:BUILD_CHANNEL = 'dev'
$Env:GIT_SHA = (git rev-parse HEAD)
$Env:BUILD_TIME = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')
flutter build apk --release `
  --build-name $Env:VERSION `
  --build-number $Env:BUILD_NUMBER `
  --dart-define=BUILD_CHANNEL=$Env:BUILD_CHANNEL `
  --dart-define=GIT_SHA=$Env:GIT_SHA `
  --dart-define=BUILD_TIME=$Env:BUILD_TIME
```

Validierung:
- `flutter analyze` sauber
- App starten: Einstellungen zeigt `Version = info.version` und `Build = buildNumber channel sha time`

