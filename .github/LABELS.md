# Reflecto Label Standards

Einheitliche Label-Struktur für Issues und PRs.

---

## 🏷️ Typ-Labels

Labels für Issue/PR-Kategorisierung.

| Label | Farbe | Beschreibung | Verwendung |
|-------|-------|--------------|------------|
| `feature` | `#0E8A16` (grün) | Neue Funktionalität | Neue Features, Erweiterungen |
| `enhancement` | `#A2EEEF` (hellblau) | Verbesserung | Optimierungen bestehender Features |
| `bug` | `#D73A4A` (rot) | Fehler | Bugs, Crashes, unerwartetes Verhalten |
| `documentation` | `#0075CA` (blau) | Dokumentation | README, Docs, Code-Kommentare |
| `quality` | `#EDEDED` (grau) | Qualität | Tests, Linting, Code-Reviews |
| `chore` | `#FEF2C0` (gelb) | Wartung | Dependencies, CI/CD, Build-Config |

---

## 📦 Bereich-Labels

Labels für Zuordnung zu App-Bereichen.

| Label | Farbe | Beschreibung |
|-------|-------|--------------|
| `ui` | `#FBCA04` (gelb) | UI/UX-Änderungen |
| `backend` | `#D4C5F9` (lila) | Backend/Firestore |
| `ai` | `#F9D0C4` (rosa) | AI/ML Features |
| `export` | `#C5DEF5` (hellblau) | Export/Import |
| `import` | `#C5DEF5` (hellblau) | Import-Funktionen |
| `analytics` | `#EDEDED` (grau) | Statistiken/Analysen |
| `gamification` | `#BFD4F2` (blau-grau) | Gamification (Streaks, Badges) |
| `notifications` | `#D93F0B` (orange) | Push-Benachrichtigungen |

---

## 🎯 Status-Labels

Labels für Workflow-Status (optional).

| Label | Farbe | Beschreibung |
|-------|-------|--------------|
| `wontfix` | `#FFFFFF` (weiß) | Wird nicht bearbeitet |
| `duplicate` | `#CFD3D7` (grau) | Duplikat eines anderen Issues |
| `invalid` | `#E4E669` (gelb-grün) | Ungültiges Issue |
| `help wanted` | `#008672` (türkis) | Community-Hilfe erwünscht |
| `good first issue` | `#7057FF` (lila) | Einstieg für neue Contributors |

---

## 🚀 Prioritäts-Labels (Optional)

Nicht verwendet, aber bei Bedarf:

| Label | Farbe | Beschreibung |
|-------|-------|--------------|
| `priority: high` | `#D73A4A` (rot) | Kritisch, sofort bearbeiten |
| `priority: medium` | `#FBCA04` (gelb) | Wichtig, bald bearbeiten |
| `priority: low` | `#0E8A16` (grün) | Nice-to-have |

---

## 📋 Label-Verwendung

### Issues
Kombiniere Typ + Bereich (z.B. `feature` + `ui` + `gamification`):
- ✅ `feature`, `ui`, `gamification` → Neues Feature mit UI im Gamification-Bereich
- ✅ `bug`, `backend` → Backend-Bug
- ✅ `documentation` → Reine Dokumentation (kein Bereich nötig)

### Pull Requests
Typ-Label automatisch via PR-Titel (Conventional Commits):
- `feat:` → `feature`
- `fix:` → `bug`
- `docs:` → `documentation`
- `chore:` → `chore`

---

## 🔧 Label-Management

### Bestehende Labels
Labels werden via GitHub Issues/Settings verwaltet.

### Neue Labels hinzufügen
```bash
gh label create "label-name" --description "Beschreibung" --color "HEXCODE"
```

### Labels aktualisieren
```bash
gh label edit "label-name" --description "Neue Beschreibung" --color "NEWHEX"
```

---

## ✅ Best Practices

1. **Minimal-Labeling:** Maximal 3-4 Labels pro Issue
2. **Konsistenz:** Immer mindestens 1 Typ-Label vergeben
3. **Milestone-Verknüpfung:** Labels ergänzen Milestones, ersetzen sie nicht
4. **Bereich optional:** Nicht jedes Issue braucht Bereich-Label
5. **Status-Labels sparsam:** Nur bei Bedarf (z.B. `wontfix`, `duplicate`)

---

**Version:** v1.5.0  
**Letzte Aktualisierung:** 17. November 2025
