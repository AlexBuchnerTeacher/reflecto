## Konzept: Dashboard mit Cards

Redesign des Week Screens mit Fokus auf **Datenvisualisierung & Insights**.

---

## Features

### 1. Hero-Card: Wochenfortschritt
- **Großer Circular Progress** mit Prozent-Anzeige (z.B. "73%")
- Zeigt Gesamtfortschritt der Woche
- Kombiniert Habits, Todos, Journal-Einträge
- Motivierender Text: "Fast geschafft!" oder "Super Woche!"

### 2. Habit-Heatmap-Card
- **7×N Grid** (7 Tage × alle aktiven Habits)
- Farbintensität zeigt Completion:
  - Dunkelgrün: Erledigt
  - Hellgrau: Nicht fällig
  - Rot: Vergessen
- Hover/Tap zeigt Details
- Scrollbar wenn viele Habits

### 3. Stimmungsgraph-Card
- **Linien-Chart** für 7 Tage
- 3 Linien:
  - Fokus (blau)
  - Energie (orange)
  - Zufriedenheit (grün)
- Y-Achse: 1-5
- X-Achse: Mo-So
- Zeigt Trends und Muster

### 4. Meal-Tracker-Summary-Card
- **Prozentuale Erfüllung** der Mahlzeiten-Logs
- Z.B. "18 von 21 Mahlzeiten eingetragen (86%)"
- Mini-Icons: 🍳 Frühstück, 🍱 Mittag, 🍽️ Abendessen
- Pro Tag: ausgefüllte vs. fehlende Mahlzeiten

### 5. Goals & Todos Card
- **Wöchentliche Goal-Completion**
- Zeigt erledigte vs. geplante Goals über 7 Tage
- Top 3 häufigste Todos
- Carry-over: Wie viele Todos wurden verschoben?

### 6. Reflection-Card
- **Wöchentliche Reflexion** (bereits vorhanden)
- Zeigt gespeicherte Reflexion an
- Button zum Bearbeiten

### 7. KI-Insights-Card
- **KI-Wochenanalyse** (bereits vorhanden)
- Generiert Insights basierend auf Daten
- Z.B. "Deine Energie war mittwochs am höchsten"

### 8. Export-Card
- **JSON Download** (bereits vorhanden)
- Quick-Share für externe Tools

---

## UI/UX Details

### Card-Layout
- **Swipeable Cards** für mobile Ansicht
- Desktop: 2-spaltig oder Masonry-Layout
- Cards haben einheitliches Padding & Border-Radius
- Schatten für Tiefe

### Card-Hierarchie
1. Hero-Card (groß, oben)
2. Stimmungsgraph + Habit-Heatmap (Haupt-Insights)
3. Meal + Goals/Todos (Sekundär)
4. Reflection + KI + Export (unten)

### Farben & Theming
- Konsistent mit bestehendem ReflectoTheme
- Farbcodierung für schnelles Erfassen
- Dunkel-Modus Support

---

## Technische Umsetzung

### Neue Widgets
- `WeekHeroCard`: Großer Fortschrittsindikator
- `WeekHabitHeatmap`: Grid-Widget für Habit-Completion
- `WeekMoodChart`: Linien-Chart für Fokus/Energie/Happiness
- `WeekMealSummary`: Meal-Tracker Übersicht
- `WeekGoalsTodosCard`: Goals & Todos Statistik

### Chart Library
- Verwende `fl_chart` package (bereits in pubspec?)
- Oder custom Canvas-Painting für Kontrolle

### Datenquellen
- `weekEntriesProvider`: 7 JournalEntry-Dokumente
- `habitsProvider`: Alle Habits
- Pro Entry:
  - Ratings: `morning.mood`, `evening.focus`, etc.
  - Habits: `completedHabits` Liste
  - Todos: `planning.todos` + `evening.todosCompletion`
  - Meals: `meals.breakfast/lunch/dinner.consumed`

### State Management
- Berechne Stats in `WeekStats.aggregate()` erweitern
- Neue Methoden:
  - `calculateHabitHeatmap()`
  - `calculateMealCompletion()`
  - `calculateGoalTodoStats()`

---

## Vorteile
✅ Schöne Datenvisualisierung motiviert
✅ Erkennen von Mustern & Trends
✅ Umfassende Wochenübersicht auf einen Blick
✅ Modular erweiterbar (neue Cards hinzufügen)
✅ Desktop & Mobile optimiert

---

## Offene Fragen
- [ ] Welche Chart-Library verwenden?
- [ ] Reihenfolge der Cards anpassbar?
- [ ] Animation beim Laden der Charts?
- [ ] Sollen Cards ausklappbar sein für mehr Details?
- [ ] Dark Mode: Farbpalette für Charts?

---

## Related
- Habit Tracker (#84)
- Week Statistics
- Meal Tracker (#84)
- Weekly Reflection

## Labels
`enhancement`, `ui/ux`, `week-screen`, `data-viz`
