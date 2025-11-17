# Reflecto Datenmodell

## entries/{yyyy-MM-dd}

- planning:
  - goals: List<String> (3 Slots, leere Slots als '')
  - todos: List<String> (3 Slots, leere Slots als '')
  - reflection: String
  - notes: String
- morning:
  - mood: String (Freitext)
  - goodThing: String
  - focus: String
- evening:
  - good: String
  - learned: String
  - improve: String
  - gratitude: String
  - todosCompletion: List<bool> (3 Slots)
  - goalsCompletion: List<bool> (3 Slots)
- ratingsMorning:
  - mood: int? (1–5)
  - energy: int? (1–5)
  - focus: int? (1–5)
- ratingsEvening:
  - mood: int? (1–5)
  - energy: int? (1–5)
  - happiness: int? (1–5)
- migratedV1: bool (true, wenn Slots normalisiert)
- updatedAt: Timestamp
- createdAt: Timestamp (gesetzt bei erstmaligem Anlegen)
 - updatedAt: Timestamp

## Hinweise
- App normalisiert verdichtete Arrays auf 3 Slots und setzt `migratedV1=true`.
- Leere Ziele/To-dos werden im UI ausgeblendet; Speicherung behält Slots für Positionsstabilität.
 - Morgen‑Ratings und Abend‑Ratings getrennt (`ratingsMorning` vs. `ratingsEvening`).
 - Neu: `createdAt` wird beim erstmaligen Anlegen eines Eintrags gesetzt; bestehende Dokumente behalten nur `updatedAt`.

## weekly_reflections/{yyyy-ww}

- motto: String?
- summaryText: String?
- aiAnalysisText: String? (plain Text extrahiert)
- aiAnalysis: Map<String, any>? (strukturierte Analyse-Daten)
- updatedAt: Timestamp

Hinweise:
- Lesezugriff ist typisiert über `WeeklyReflection`; Schreibzugriff erfolgt entweder per Map-Merge (`saveWeeklyReflection`) oder typisiert (`saveWeeklyReflectionModel`).

## users/{uid}/habits/{habitId}

Gewohnheiten/Routinen, die ein Nutzer verfolgt.

- id: String (Firestore-generiert)
- title: String (z.B. "10 Minuten lesen")
- category: String (z.B. "🔥 GESUNDHEIT", "🚴 SPORT")
- color: String (Hex, z.B. "#5B50FF")
- frequency: String ("daily" | "weekly_days" | "weekly_target" | "irregular")
  - `daily`: Jeden Tag geplant
  - `weekly_days`: Bestimmte Wochentage (siehe `weekdays`)
  - `weekly_target`: Ziel-Anzahl pro Woche (siehe `weeklyTarget`)
  - `irregular`: Kein fester Plan
- weekdays: List<int>? (1=Mo ... 7=So, nur für `weekly_days`)
- weeklyTarget: int? (Ziel-Tage pro Woche, nur für `weekly_target`)
- reminderTime: String? (HH:mm Format, optional)
- sortIndex: int? (Sortierung innerhalb Kategorie, 0/10/20/...)
- streak: int (Aktuelle Streak-Länge für tägliche Habits)
- completedDates: List<String> (yyyy-MM-dd Format)
- createdAt: Timestamp
- updatedAt: Timestamp

Hinweise:
- Streak-Berechnung nur für `frequency=daily`
- Legacy-Daten mit `frequency=weekly` werden als `weekly_days` interpretiert
- `sortIndex` ermöglicht Reordering innerhalb einer Kategorie (10er-Schritte)

## habit_templates/{templateId}

Globale Vorlagen für Habits (server-seitig, read-only für normale User).

- id: String (z.B. "gesundheit_2-liter-wasser")
- title: String
- category: String (z.B. "🔥 GESUNDHEIT")
- color: String (Hex)
- frequency: String
- weekdays: List<int>? (falls frequency=weekly_days)
- weeklyTarget: int? (falls frequency=weekly_target)
- reminderTime: String? (optional)

Hinweise:
- Seeding via Admin-Funktion (`HabitTemplateService.seedTemplates`)
- Templates werden im FAB-Bottom-Sheet angezeigt
- 40+ kuratierte Templates in 8 Kategorien

## users/{uid}/meals/{yyyy-MM-dd}

Tages-Essenslog (Frühstück/Mittag/Abend).

- id: String (yyyy-MM-dd)
- breakfast: bool
- lunch: bool
- dinner: bool
- breakfastNote: String? (Gericht/Notiz)
- lunchNote: String? (Gericht/Notiz)
- dinnerNote: String? (Gericht/Notiz)
- createdAt: Timestamp
- updatedAt: Timestamp

Hinweise:
- Dokument wird automatisch bei erstem Toggle/Notiz erstellt
- Partial Updates via merge (nur geänderte Felder)
- Anzeige im Day-Screen unter Morgen-Sektion

## users/{uid}/weeklyStats (future)

Wöchentliche Aggregationen und Statistiken (geplant für v1.6.0).

**Geplante Felder:**
- weekId: String (yyyy-ww)
- totalHabits: int
- completedHabits: int
- completionRate: double (0.0-1.0)
- streakCounts: Map<String, int> (habitId → streak)
- topHabits: List<String> (habitIds mit höchster Completion)
- flopHabits: List<String> (habitIds mit niedriger Completion)
- updatedAt: Timestamp

Hinweise:
- Noch nicht implementiert (siehe #92, #101)
- Berechnung erfolgt clientseitig oder via Cloud Functions
- Snapshot am Sonntag 20:00 für Weekly Review

## users/{uid}/userSettings (future)

User-spezifische Einstellungen (geplant).

**Geplante Felder:**
- theme: String? ("light" | "dark" | "system")
- notifications: bool (Push-Benachrichtigungen aktiviert)
- weekStartDay: int (1=Mo, 7=So)
- reminderTime: String? (Standard-Erinnerungszeit HH:mm)
- language: String? (ISO 639-1, z.B. "de", "en")
- updatedAt: Timestamp

Hinweise:
- Noch nicht implementiert
- Aktuell: Einstellungen nur in UI-State (nicht persistiert)

