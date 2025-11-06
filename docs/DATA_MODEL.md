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

## Hinweise
- App normalisiert verdichtete Arrays auf 3 Slots und setzt `migratedV1=true`.
- Leere Ziele/To-dos werden im UI ausgeblendet; Speicherung behält Slots für Positionsstabilität.
- Morgen‑Ratings und Abend‑Ratings getrennt (`ratingsMorning` vs. `ratingsEvening`).

