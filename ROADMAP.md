# Reflecto Roadmap 2025

Diese Roadmap definiert die strategischen Entwicklungsphasen für Reflecto im Jahr 2025.

---

## 📋 Phase 1 – Foundation & Stability (Q4 2024 - Q1 2025)

**Status:** ✅ **Abgeschlossen** (v1.5.0)

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

### In Progress
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

## 🚀 Phase 2 – Productivity MVP (Q1 2025)

**Status:** 🔄 **In Planung**

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

## 📚 Phase 2.5 – Documentation & Quality (parallel zu Phase 2)

### Dokumentation
- **#108** - ARCHITECTURE.md
  - Riverpod State-Management
  - Provider-Struktur
  - Services (Firestore, Auth)
  - UI-Layer
  - Sync-Flow (Tag, Woche)
  
- **#105** - Firestore Schema
  - `habits` Collection
  - `weeklyStats`
  - `userSettings`
  - Felder + Datentypen
  - Migration Hinweise

- **#106** - Repo Standards
  - Issue Templates
  - Pull Request Templates
  - Label-Standards
  - CONTRIBUTING Update

### Testing (#103)
- Streak-Tests
- Smart Sorting Tests
- Weekly-Completion Tests
- Coverage: 50%+

---

## 🎯 Phase 3 – Scaling & UX (Q2 2025)

**Status:** 🔮 **Future**

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

## 🌟 Phase 4 – Future Options (Q3-Q4 2025)

**Status:** 🔮 **Vision**

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

## 🎯 MVP Output (Phase 1 + 2)

Wenn Phase 1 und 2 abgeschlossen sind, haben wir:

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

- ❌ Push Notifications (kommt Phase 3)
- ❌ Offline-First (kommt Phase 3)
- ❌ Crashlytics (kommt Phase 3)
- ❌ Dark Mode (kommt Phase 3)
- ❌ Store-Pipelines (kommt Phase 4)
- ❌ i18n/Lokalisierung
- ❌ Große Heatmaps / erweiterte Statistiken

---

## 📅 Timeline

| Phase | Zeitraum | Status |
|-------|----------|--------|
| Phase 1 | Q4 2024 - Q1 2025 | ✅ Mostly Done |
| Phase 2 | Q1 2025 | 🔄 In Progress |
| Phase 2.5 | Q1 2025 | 🔄 In Progress |
| Phase 3 | Q2 2025 | 🔮 Planned |
| Phase 4 | Q3-Q4 2025 | 🔮 Vision |

---

## 🔗 Related Issues

### Phase 1 (Done)
- #85, #86, #87 - Week Screen Redesign ✅
- #56 - KI-Auswertung ✅
- #57 - Habit Tracker ✅
- #102, #107 - CI/CD ✅

### Phase 2 (In Progress)
- #92, #99 - Habit-Insights
- #93, #100 - Smart Habits
- #101, #109 - Weekly Review
- #91 - Custom Habit Order

### Phase 2.5 (Documentation)
- #103 - Core Tests
- #105 - Firestore Schema Docs
- #106 - Repo Standards
- #108 - ARCHITECTURE.md

### Phase 3 (Future)
- #47 - Push Notifications

### Meta Issues
- #97 - Diese Roadmap
- #98 - MVP Definition

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
