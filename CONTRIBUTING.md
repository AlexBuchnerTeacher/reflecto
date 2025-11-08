# Contributing & Reflecto Git Workflow

Dieses Dokument beschreibt den vereinbarten Arbeitsablauf (Branches, Commits, PRs, Releases) für dieses Repository. Bitte halte dich bei jeder Änderung daran.

## 🧭 Reflecto Git Workflow

- Arbeit immer über Feature-/Fix-Branches, niemals direkt auf `main`.
- Kleine, fokussierte PRs mit kurzer Begründung und, wo sinnvoll, Screenshot/GIF.
- CI (Analyzer/Lint/Build/Tests) muss grün sein, bevor gemerged wird.

## 📁 Branch‑Struktur

| Branch             | Zweck                             | Besonderheit                              |
| ------------------ | --------------------------------- | ----------------------------------------- |
| `main`             | stabile Version, produktionsreif  | keine direkten Commits (geschützt)        |
| `dev`              | aktive Entwicklung                | Feature-/Fix‑Branches werden hier gemerged |
| `feature/<name>`   | neue Features/Module              | z. B. `feature/streak_counter`            |
| `fix/<name>`       | Bugfixes                          | z. B. `fix/firestore_sync`                |
| `chore/<name>`     | Wartung/CI/Infra                  | z. B. `chore/gh_actions_pages`            |
| `docs/<name>`      | Dokumentation                     | optional                                   |
| `test/<name>`      | experimentelle Ideen              | optional                                   |

Hinweise:
- Branch‑Namen nur Kleinbuchstaben, Trennzeichen `_` oder `-`.
- Falls `dev` (noch) nicht existiert, kann initial direkt nach `main` gemerged werden; anschließend bitte `dev` als Standard‑Integrationszweig etablieren.

## ✍️ Commit‑Regeln

Conventional Commits erlaubt – ergänzt um Emojis. Subjekt im Imperativ, kurz (~50–72 Zeichen), optionaler Scope in Klammern.

| Kategorie | Emoji | Beispiel                                          |
| --------- | ----- | ------------------------------------------------- |
| ✨ Feature | `✨`   | `✨(streak): Add Streak Counter mit SharedPrefs`  |
| 🐛 Fix    | `🐛`   | `🐛(day): Fix NullCheck in DayScreen`             |
| 🔧 Config | `🔧`   | `🔧(rules): Update Firestore Security Rules`      |
| 🧱 Refactor | `🧱` | `🧱(ui): Struktur von Widgets vereinfacht`        |
| 📄 Docs   | `📄`   | `📄(readme): Ergänze Setup-Anleitung`            |
| 🚀 Deploy | `🚀`   | `🚀 Release v1.2.0`                               |

Weitere Regeln:
- Eine Änderung pro Commit (so weit sinnvoll).
- Commit‑Body für „Warum“/Kontext nutzen; referenziere Issues: `fixes #23`.

## 🔐 Best Practices

- Kein direkter Push auf `main`.
- PRs dokumentieren (Kurzbeschreibung, ggf. Screenshot/Video, Testhinweis).
- Issue‑Nummern in Commits/PR beschreiben (z. B. `fixes #123`).
- Releases taggen nach SemVer (`v1.0.0`, `v1.1.0`, …) und `CHANGELOG.md` pflegen.
- Automatische Checks über GitHub Actions: Flutter‑Build, Analyze/Lint, Tests.

## 🚢 GitHub Pages

- `gh-pages` dient als Veröffentlichungsquelle für die Flutter Web‑Builds.
- Der Deploy‑Workflow überschreibt `gh-pages` bei jedem Release/Deploy.
- Optional (empfohlen): Deploys nur bei Tags/Releases ausführen.

## 🧠 Empfohlene GitHub Actions

| Zweck              | Datei                              | Trigger             |
| ------------------ | ---------------------------------- | ------------------- |
| Flutter CI Build   | `.github/workflows/flutter.yml`    | `on: pull_request`  |
| Linter & Analyzer  | `.github/workflows/analyze.yml`    | `on: push`          |
| Version Tagging    | `.github/workflows/release.yml`    | `on: push -> main`  |

Hinweise:
- Für Releases: Version in `pubspec.yaml` erhöhen, `CHANGELOG.md` aktualisieren, Tag setzen (z. B. via `release.yml`).
- Pages‑Deploys: nur aus geprüften Artefakten (CI‑Build), nicht manuell.

## 🔁 PR‑Checkliste

- [ ] Branch‑Name gemäß Konvention
- [ ] Commit‑Nachrichten gemäß Regeln
- [ ] `flutter analyze` sauber
- [ ] Relevante Tests hinzugefügt/geprüft (falls sinnvoll)
- [ ] `CHANGELOG.md` aktualisiert (bei user‑sichtbaren Änderungen)
- [ ] Screenshots/GIFs bei UI‑Änderungen

## 🧭 Entscheidungsregeln (kurz)

- „Klein und oft“: kleine PRs mergen, Folge‑PRs statt Monster‑PRs.
- Konflikte: lieber rebase (linear) als merge, sofern Review‑Kontext erhalten bleibt.
- Schutzregeln: `main` geschützt; Rebase/Squash für Feature‑PRs bevorzugt.

---

Fragen/Änderungen am Prozess bitte per Issue/PR vorschlagen.
