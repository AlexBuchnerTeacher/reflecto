## Konzept: Wochenkalender mit Tagesübersicht

Redesign des Week Screens mit Fokus auf **schneller Navigation & visueller Tagesübersicht**.

---

## Features

### 1. 7-Tage-Grid (Mo-So)
- **Kompakte Tageskacheln** in einem horizontalen oder Grid-Layout
- Jede Kachel zeigt:
  - **Datum** (z.B. "16. Nov")
  - **Wochentag** (z.B. "Sa")
  - **Mini-Stimmungsindikator** (Emoji oder Farbkreis basierend auf Abend-Mood)
  - **Habit-Progress** (z.B. "5/8" erledigte Habits)
  - **Todo-Progress** (z.B. "3/5" erledigte Todos)
  - **Tap-Aktion**: Navigiert zum DayScreen für diesen Tag

### 2. Wochenfortschritt-Header
- **Großer Progress-Indikator** über dem Grid
- Zeigt Gesamthabit-Completion der Woche (z.B. "73% abgeschlossen")
- Könnte Circular Progress oder Linear Progress sein

### 3. Ausklappbare Detail-Sektionen (optional)
Unter dem Grid:
- **Statistiken** (Fokus/Energie/Zufriedenheit - wie bisher)
- **KI-Wochenanalyse** (bereits vorhanden)
- **Export** (JSON Download - bereits vorhanden)

---

## UI/UX Details

### Tageskachel Design
```
┌─────────────┐
│ Mo 11. Nov  │
│             │
│   😊 5/8    │  ← Mood Emoji + Habits
│   ✓ 3/5     │  ← Todos
└─────────────┘
```

### Interaktionen
- **Tap auf Kachel**: Navigation zu DayScreen(date)
- **Farbcodierung**:
  - Grün: Tag vollständig ausgefüllt & gute Completion
  - Gelb: Teilweise ausgefüllt
  - Grau: Keine Daten für diesen Tag
  - Hellblau: Heute (Highlight)

### Wochennavigation
- Behalten: Pfeile links/rechts, "Heute"-Button
- Format: "11. - 17. November 2025"

---

## Technische Umsetzung

### Datenquellen
- `weekEntriesProvider`: Liefert 7 JournalEntry-Dokumente
- `habitsProvider`: Alle Habits für Completion-Berechnung
- Pro Tag:
  - Mood: `evening.mood` oder `morning.mood`
  - Habits: Anzahl completed vs. scheduled
  - Todos: Anzahl aus `planning.todos` vs. `evening.todosCompletion`

### Neue Widgets/Logic
- `WeekCalendarGrid`: 7-Tage Grid Widget
- `WeekDayCard`: Einzelne Tageskachel
- `WeekProgressHeader`: Wochenfortschritt-Anzeige
- `WeekStatsCalculator`: Aggregiert Habit/Todo-Completion über 7 Tage

### Navigation
```dart
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DayScreen(initialDate: selectedDate),
    ),
  );
}
```

---

## Vorteile
✅ Schneller visueller Überblick über die gesamte Woche
✅ Direkter Zugriff auf einzelne Tage mit einem Tap
✅ Motivation durch sichtbare Fortschrittsanzeige
✅ Erkennen von Mustern ("Montags bin ich immer unproduktiv")
✅ Mobile-first: funktioniert gut auf kleinen Screens

---

## Offene Fragen
- [ ] Grid-Layout: 7 Spalten horizontal oder 2×4 Grid?
- [ ] Mood-Indikator: Emoji oder farbiger Kreis?
- [ ] Sollen zukünftige Tage ausgegraut sein?
- [ ] Animation beim Wechsel zwischen Wochen?

---

## Related
- Habit Tracker (#84)
- Day Screen Navigation
- Week Statistics

## Labels
`enhancement`, `ui/ux`, `week-screen`
