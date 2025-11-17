# Reflecto Roadmap 2025

Diese Roadmap definiert die strategischen Entwicklungsmilestones für Reflecto im Jahr 2025.

---

## 📋 v1.5.0 – Foundation & Stability

**Status:** ✅ **Abgeschlossen**  
**Milestone:** [v1.5.0](https://github.com/AlexBuchnerTeacher/reflecto/milestone/5)

### Ziel
Stabile technische Basis mit CI/CD, Tests und sauberer Dokumentation.

### Deliverables
- ✅ CI/CD Pipeline (#102, #107)
  - GitHub Actions: Lint, Test, Build
  - Automatische Checks bei PRs
  - Dependabot Integration
- ✅ Week Screen Redesign (#85, #86, #87)
  - WeekHeroCard mit circular progress
  - WeekRadialStats Visualisierung
  - Simplified Navigation
- ✅ KI-Auswertung (#56)
  - ChatGPT Export/Import Pipeline
  - Markdown-formatierte Anzeige
- ✅ Habit Tracker Grundlagen (#57)
  - CRUD für Habits
  - Streak Tracking
  - Daily Completion

### In Progress (Teil von v1.5.0)
- 📖 Dokumentation (#105, #106, #108)
  - [ ] ARCHITECTURE.md
  - [ ] Firestore Schema Dokumentation
  - [ ] Repo Standards (Templates, Labels)
- 🧪 Core Unit Tests (#103)
  - [ ] Streak-Logik Tests
  - [ ] Sorting-Tests
  - [ ] Week-Completion Tests
  - Coverage Target: 50%

---

## 🚀 v1.6.0 – Productivity MVP

**Status:** 🔄 **In Planung**  
**Milestone:** [v1.6.0](https://github.com/AlexBuchnerTeacher/reflecto/milestone/7)

### Ziel
Ein stabiler DayScreen mit Smart Feedback, intelligenter Priorisierung und Weekly Review.  
**Ziel:** Tägliche Klarheit, Fokus und Motivation.

### Features

#### 2.1 Habit-Insights (#92, #99)
**Status:** Planned  
**Labels:** `feature`, `ui`, `analytics`

Schnelle Orientierung im DayScreen: Tagesbilanz, Kategorie-Fortschritt, Trends und Spotlight.

**Deliverables:**
- Tagesbilanz (x/y erledigt)
- Kategorie-Fortschritt (farbcodierte Balken)
- Top-3-Trends (Streaks, Konstanz)
- Spotlight-Empfehlung (z.B. "Mind: 1/4 erledigt")

**Akzeptanzkriterien:**
- Insights erscheinen automatisch
- Keine Benutzerinteraktion nötig
- Berechnung clientseitig
- Keine Performance-Einbußen

#### 2.2 Smart Habits – Auto-Priorisierung (#93, #100)
**Status:** Planned  
**Labels:** `feature`, `ui`

Intelligente Sortierung der Habits nach Relevanz.

**Deliverables:**
- Prioritätslevel: Hoch (🔴), Mittel (⚪), Niedrig (⚫)
- Score-Modell (Streak, Konstanz, Skips, Zeitmatching)
- "Smart Order" Button
- Toggle für Auto-Priorisierung (an/aus)

**Score-Formel:**
- Streak-Länge
- Konstanz der letzten 7 Tage
- Skip-Häufigkeit
- Zeitliche Passung (Morgen/Abend)

**Akzeptanzkriterien:**
- Korrekte Prioritäts-Berechnung
- Habits werden richtig sortiert
- Badges/Icons am Habit sichtbar
- Deaktivierbar

#### 2.3 Weekly Review (#101, #109)
**Status:** Planned  
**Labels:** `feature`, `analytics`

Wöchentliche Erfolgsübersicht mit Streaks, Quote, Top/Flop-Habits.

**Deliverables:**
- Erfolgsquote der Woche
- Top/Flop-Habits
- Streak-Übersicht
- Automatischer Snapshot (Sonntag 20:00)
- UI für Review-Anzeige am Wochenstart (Montag)

**Akzeptanzkriterien:**
- Snapshot wird korrekt erstellt
- Anzeige erscheint montags automatisch
- Keine Firestore-Writes im UI (nur Reads)
- Review wird nur einmal pro Woche angezeigt

#### 2.4 Individuelle Habit-Sortierung (#91)
**Status:** Planned  
**Labels:** `feature`, `ui`

**Deliverables:**
- Neues Feld `orderIndex` pro Habit
- Drag & Drop Sortierung (ReorderableListView)
- Kategorien steuern weiterhin nur die Farbe
- Abgeschlossene Habits wandern automatisch nach unten

---

## 🎯 v1.7.0 – Scaling & UX

**Status:** 🔮 **Geplant**  
**Milestone:** [v1.7.0](https://github.com/AlexBuchnerTeacher/reflecto/milestone/8)

### Planned Features
- Offline-Strategie (Caching)
- Crashlytics Integration
- Performance Profiling
- Dark Mode Check + A11y Improvements
- Push Notifications (#47)
  - Tägliche Erinnerungen
  - Streak-Warnungen
  - Smart Timing

### UI/UX Enhancements
- Animations & Transitions
- Micro-Interactions
- Haptic Feedback
- Onboarding Flow

---

## 🌟 v2.0.0 – Future Vision

**Status:** 🔮 **Vision**  
**Milestone:** [v2.0.0](https://github.com/AlexBuchnerTeacher/reflecto/milestone/9)

### Automation
- Release-Automation
- iOS/Android Build Pipelines
- Automated App Store Deployments

### Community Features
- User Profiles
- Shared Weekly Reviews
- Community Challenges
- Habit Templates Library

### Advanced Analytics
- Heatmaps
- Multi-Week Comparisons
- ML-based Insights
- Predictive Suggestions

---

## 🎯 MVP Output (v1.5.0 + v1.6.0)

Wenn v1.5.0 und v1.6.0 abgeschlossen sind, haben wir:

✅ **Stabiler DayScreen** mit Analytics  
✅ **Intelligente Habit-Reihenfolge**  
✅ **Weekly Review** mit automatischer Generierung  
✅ **Saubere CI/CD** Pipeline  
✅ **Dokumentierte Architektur**  
✅ **Repo-Standards** (Templates, Labels)  
✅ **Core Tests** (50%+ Coverage)

---

## 📊 MVP Erfolgskriterien

- [ ] App startet < 2s
- [ ] CI grün über die letzten 10 Runs
- [ ] Mind. 1 Interaktion pro User/Tag
- [ ] 50% nutzen den Weekly Review mind. 1x
- [ ] Coverage ≥ 50%
- [ ] Dokumentation vollständig

---

## 🚫 MVP Ausschlüsse

Diese Features sind **bewusst nicht** im MVP enthalten:

- ❌ Push Notifications (kommt v1.7.0)
- ❌ Offline-First (kommt v1.7.0)
- ❌ Crashlytics (kommt v1.7.0)
- ❌ Dark Mode (kommt v1.7.0)
- ❌ Store-Pipelines (kommt v2.0.0)
- ❌ i18n/Lokalisierung
- ❌ Große Heatmaps / erweiterte Statistiken

---

## 📅 Timeline

| Milestone | Zeitraum | Status |
|-----------|----------|--------|
| v1.5.0 | Q4 2024 - Q1 2025 | ✅ Mostly Done |
| v1.6.0 | Q1 2025 | 🔄 In Progress |
| v1.7.0 | Q2 2025 | 🔮 Planned |
| v2.0.0 | Q3-Q4 2025 | 🔮 Vision |

---

## 🔗 Related Issues

### v1.5.0 (Abgeschlossen)
- #85, #86, #87 - Week Screen Redesign ✅
- #56 - KI-Auswertung ✅
- #57 - Habit Tracker ✅
- #102, #107 - CI/CD ✅
- #103 - Core Tests 🔄
- #105 - Firestore Schema Docs 🔄
- #106 - Repo Standards 🔄
- #108 - ARCHITECTURE.md 🔄

### v1.6.0 (In Planung)
- #92, #99 - Habit-Insights
- #93, #100 - Smart Habits
- #101, #109 - Weekly Review
- #91 - Custom Habit Order

### v1.7.0 (Zukunft)
- #47 - Push Notifications

### Geschlossen
- #97 - Roadmap Definition (durch dieses Dokument ersetzt)
- #98 - MVP Definition (integriert in v1.6.0)

---

## 🎯 Nächste Schritte

1. **Dokumentation abschließen** (#105, #106, #108)
2. **Core Tests implementieren** (#103)
3. **Habit-Insights entwickeln** (#92, #99)
4. **Smart Habits bauen** (#93, #100)
5. **Weekly Review implementieren** (#101, #109)

---

*Letzte Aktualisierung: 17. November 2025*  
*Version: 1.5.0*
