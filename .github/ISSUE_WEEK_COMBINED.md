## Konzept: Week Screen Redesign - Kombiniert

Redesign des Week Screens als Kombination aus **Wochenkalender mit Tagesübersicht** (Option 1) und **Dashboard mit Cards** (Option 4).

Design-Sprache: Angelehnt an das **Day Screen Karussell** für konsistente UX.

---

## Features

### 1. Wochennavigation mit Karussell (wie Day Screen)
- **Horizontales 7-Tage-Karussell** (Mo-So)
- Design **identisch zum Day Screen Carousel**:
  - Kompakte Tageskacheln
  - Aktiver Tag hervorgehoben
  - Swipe-Gesten für Navigation
  - Smooth Scrolling
- Jede Kachel zeigt:
  - **Wochentag** (z.B. "Mo")
  - **Datum** (z.B. "11")
  - **Mini-Stimmungsindikator** (kleiner farbiger Punkt/Kreis basierend auf Mood)

### 2. Wochenfortschritt Hero-Card
- **Großer Circular Progress** (wie Option 4)
- Zeigt Gesamtfortschritt: Habits + Todos + Journal-Completion
- Prozent-Anzeige (z.B. "73%")
- Motivierender Text: "Fast geschafft!" / "Super Woche!"
- Farbcodierung: grün bei >80%, gelb bei 50-80%, grau bei <50%

### 3. Tagesdetail-Karte (unter Karussell)
Zeigt Details für den **im Karussell ausgewählten Tag**:
- **Datum-Header**: "Montag, 11. November"
- **Stimmung**: Emoji + Werte (Fokus/Energie/Zufriedenheit)
- **Habits**: "5 von 8 erledigt" + Mini-Liste (nur Top 3)
- **Todos**: "3 von 5 erledigt" + Mini-Liste
- **Mahlzeiten**: 🍳🍱🍽️ (ausgefüllt = grün, leer = grau)
- **Tap-Aktion**: Navigiert zum DayScreen(selectedDate)

### 4. Dashboard-Cards (scrollbar)
Darunter: **Card-basierte Insights** für die gesamte Woche

#### 4.1 Habit-Heatmap-Card
- **7×N Grid** (7 Tage × alle aktiven Habits)
- Farbintensität: Dunkelgrün=erledigt, Grau=nicht fällig, Rot=vergessen
- Horizontales Scrollen wenn viele Habits
- Header: "Habit-Verlauf"

#### 4.2 Stimmungsgraph-Card
- **Linien-Chart** für 7 Tage
- 3 Linien: Fokus (blau), Energie (orange), Zufriedenheit (grün)
- Y-Achse: 1-5, X-Achse: Mo-So
- Header: "Wochenverlauf"

#### 4.3 Meal-Tracker-Summary-Card
- Prozentuale Erfüllung der Mahlzeiten
- "18 von 21 Mahlzeiten (86%)"
- Mini-Icons pro Tag: 🍳🍱🍽️
- Header: "Ernährung"

#### 4.4 Goals & Todos Summary-Card
- Wöchentliche Completion-Rate
- Top 3 häufigste Todos
- Carry-over-Statistik
- Header: "Ziele & Aufgaben"

#### 4.5 Reflection-Card
- Wöchentliche Reflexion (bereits vorhanden)
- Button zum Bearbeiten
- Header: "Wochenreflexion"

#### 4.6 KI-Insights-Card
- KI-Wochenanalyse (bereits vorhanden)
- Generierte Insights
- Header: "KI-Analyse"

#### 4.7 Export-Card
- JSON Download (bereits vorhanden)
- Header: "Daten exportieren"

---

## UI/UX Details

### Layout-Hierarchie
```
┌─────────────────────────────────┐
│  Wochennavigation (Pfeile)      │
├─────────────────────────────────┤
│  [Mo][Di][Mi][Do][Fr][Sa][So]  │  ← Karussell (wie Day Screen)
│   11  12  13  14  15  16  17    │
├─────────────────────────────────┤
│                                 │
│    ┌─────────────────┐         │
│    │   73%           │         │  ← Hero Progress
│    │ Fast geschafft! │         │
│    └─────────────────┘         │
├─────────────────────────────────┤
│  Montag, 11. November           │
│  😊  Fokus 4 | Energie 5        │  ← Tagesdetail-Karte
│  Habits: 5/8  Todos: 3/5        │     (klickbar)
│  🍳🍱🍽️                          │
├─────────────────────────────────┤
│  📊 Habit-Verlauf               │
│  [Heatmap Grid]                 │  ← Cards (scrollbar)
├─────────────────────────────────┤
│  📈 Wochenverlauf               │
│  [Linien-Chart]                 │
├─────────────────────────────────┤
│  🍽️ Ernährung                   │
│  18/21 Mahlzeiten (86%)         │
└─────────────────────────────────┘
   ... weitere Cards
```

### Karussell-Design (identisch zu Day Screen)
- **Verwendung des bestehenden DayWeekCarousel**
- Gleicher Look & Feel
- Swipe-Support
- Aktiver Tag: farbig hervorgehoben
- Nicht-aktive Tage: leicht ausgegraut

### Interaktionen
1. **Karussell-Navigation**: 
   - Tap auf Tag → lädt Tagesdetail-Karte
   - Swipe → nächster/vorheriger Tag
   - Wochennavigation-Pfeile → vor/zurück (7 Tage)

2. **Tagesdetail-Karte**:
   - Tap → Navigiert zu DayScreen(selectedDate)

3. **Cards**:
   - Scrollbar für alle Dashboard-Cards
   - Cards ausklappbar für mehr Details (optional)

### Farbcodierung
- **Grün**: Gut (>80% Completion)
- **Gelb**: Mittel (50-80%)
- **Grau**: Niedrig (<50%)
- **Rot**: Vergessen/nicht erledigt
- **Hellblau**: Heute (Highlight)

---

## Technische Umsetzung

### Wiederverwendung bestehender Komponenten
- `DayWeekCarousel` → direkt wiederverwenden
- `WeekNavigationBar` → anpassen für Karussell-Integration
- `WeekStatsCard` → umbauen zu einzelnen Dashboard-Cards

### Neue Widgets
- `WeekCarouselView`: Wrapper für DayWeekCarousel im Week-Kontext
- `WeekHeroCard`: Circular Progress mit Gesamt-Completion
- `WeekDayDetailCard`: Tagesdetail-Karte (klickbar)
- `WeekHabitHeatmap`: 7×N Grid für Habits
- `WeekMoodChart`: Linien-Chart (fl_chart package)
- `WeekMealSummary`: Meal-Tracker Übersicht
- `WeekGoalsTodosCard`: Goals & Todos Statistik

### State Management
```dart
class _WeekScreenState {
  DateTime _anchor; // aktuelle Woche
  DateTime _selectedDay; // im Karussell ausgewählter Tag
  
  void _onDaySelected(DateTime day) {
    setState(() => _selectedDay = day);
  }
  
  void _onWeekChanged(int delta) {
    setState(() {
      _anchor = _anchor.add(Duration(days: delta * 7));
      _selectedDay = _anchor; // reset zu Montag
    });
  }
}
```

### Datenquellen
- `weekEntriesProvider(_anchor)`: 7 JournalEntry-Dokumente
- `habitsProvider`: Alle Habits
- `dayDocProvider(_selectedDay)`: Einzeltag für Detail-Karte
- Pro Tag:
  - Mood: `evening.mood` oder `morning.mood`
  - Ratings: `evening.focus`, `evening.energy`, `evening.happiness`
  - Habits: via `habitServiceProvider.isCompletedOnDate()`
  - Todos: `planning.todos` vs. `evening.todosCompletion`
  - Meals: `meals.breakfast/lunch/dinner.consumed`

### Navigation zu DayScreen
```dart
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => HomeScreen(), // mit initialIndex=0 (Day)
    ),
  );
  // Oder direkter:
  // Navigator.push(..., DayScreen(initialDate: _selectedDay))
}
```

---

## Implementierungs-Schritte

### Phase 1: Karussell-Integration
- [x] DayWeekCarousel im WeekScreen einbinden
- [ ] State für _selectedDay hinzufügen
- [ ] Wochennavigation (Pfeile) anpassen
- [ ] Callback für onDaySelected implementieren

### Phase 2: Hero & Tagesdetail
- [ ] WeekHeroCard erstellen (Circular Progress)
- [ ] Gesamt-Completion-Berechnung (Habits + Todos + Journal)
- [ ] WeekDayDetailCard erstellen
- [ ] Navigation zu DayScreen implementieren

### Phase 3: Dashboard-Cards
- [ ] WeekHabitHeatmap (7×N Grid)
- [ ] WeekMoodChart (Linien-Chart via fl_chart)
- [ ] WeekMealSummary
- [ ] WeekGoalsTodosCard
- [ ] Bestehende Reflection/KI/Export-Cards integrieren

### Phase 4: Polish
- [ ] Animations beim Wechsel
- [ ] Loading States
- [ ] Error Handling
- [ ] Dark Mode Support
- [ ] Responsive Layout (Desktop/Tablet)

---

## Vorteile der Kombination
✅ **Konsistente UX**: Karussell wie im Day Screen
✅ **Schnelle Navigation**: Direkt zu einzelnen Tagen
✅ **Umfassende Insights**: Dashboard-Cards für Analyse
✅ **Motivation**: Visueller Fortschritt auf einen Blick
✅ **Flexibilität**: Modular erweiterbar
✅ **Mobile-optimiert**: Swipe-Gesten + scrollbare Cards

---

## Offene Fragen
- [ ] Chart-Library: fl_chart oder custom?
- [ ] Soll Tagesdetail-Karte eine Bottom Sheet sein?
- [ ] Animation beim Tag-Wechsel im Karussell?
- [ ] Cards: feste Reihenfolge oder drag-to-reorder?
- [ ] Sollen zukünftige Tage ausgegraut sein?

---

## Related
- Day Screen Carousel (#existing)
- Habit Tracker (#84)
- Week Statistics (#85, #86)
- Meal Tracker (#84)

## Labels
`enhancement`, `week-screen`, `ui/ux`, `data-viz`
