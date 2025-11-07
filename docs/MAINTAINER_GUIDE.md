# Reflecto – Maintainer Guide

Dieser Guide beschreibt die wichtigsten Schritte für Betrieb und Zusammenarbeit über GitHub (ohne Mobile Deployments).

## 1) GitHub Pages aktivieren
- Repo → Settings → Pages → Build and deployment → Source: „GitHub Actions“.
- Der Workflow `.github/workflows/gh-pages.yml` kümmert sich um Build & Deploy.

## 2) Labels initial anlegen
- Repo → Actions → „Seed Labels“ → „Run workflow“ (Branch: `main`).
- Erstellt/aktualisiert Labels wie `type:bug`, `type:feature`, `prio:*`, `area:*`.

## 3) Pull Requests & CI
- Schreibe PR‑Titel nach „Conventional Commits“ (z. B. `feat:`, `fix:`, `chore:`). Der Workflow `semantic-pr.yml` prüft das.
- CI (Workflow „Flutter CI“) führt Format‑Check, Analyze, Tests (Coverage) aus und baut einen Web‑Release‑Build.
- Artefakte: `coverage/lcov.info` und `web-build` hängen am Workflow‑Run.
- PR‑Preview: Jede PR gegen `main` deployed eine Web‑Preview via GitHub Pages. Der Link erscheint im PR unter „Deployments“.

## 4) Live‑Deploy
- Merge auf `main` → GitHub Pages Workflow deployed automatisch die Web‑App.
- Base‑Pfad ist `/reflecto/` (bereits im Build‑Befehl konfiguriert).

## 5) Releases (optional)
- Tag `vX.Y.Z` pushen → Workflow `release.yml` erstellt ein GitHub Release mit Notes.

## 6) Firebase Hinweis
- Für Web‑Login die Domain `alexbuchnerteacher.github.io` in Firebase Auth → Authorized domains eintragen.

## 7) Nützliche Dateien
- `.github/PULL_REQUEST_TEMPLATE.md` – PR Checkliste
- `.github/ISSUE_TEMPLATE/*` – Issue‑Formulare
- `.github/dependabot.yml` – Wöchentliche Updates (pub, actions)
- `.github/CODEOWNERS` – Repository‑Owner
- `docs/ARCHITECTURE.md` – Architekturüberblick

## 8) Tipps
- Kleine Branches/PRs, früh Feedback einholen.
- `flutter analyze` und `flutter test` lokal laufen lassen, bevor du pushst.
- Screenshots/Videos im PR helfen bei UI‑Themen enorm.
