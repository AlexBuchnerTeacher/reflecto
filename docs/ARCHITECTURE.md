# Reflecto – Architekturüberblick

Ziel: Schlanke, testbare Struktur für Flutter + Firebase + Riverpod.

## Ebenen
- UI (`lib/screens`, `lib/widgets`): Stellt Views/Widgets bereit.
- State/Logic (`lib/providers`): Riverpod Provider, Business‑Logik, Mappings.
- Services (`lib/services`): Firebase/HTTP Zugriffe, reine Seiteneffekte.
- Models (`lib/models`): Datenklassen und (de-)Serialisierung.

## State Management
- Riverpod (`flutter_riverpod`):
  - `Provider`/`StateNotifierProvider` für synchronen/reaktiven State.
  - Keine globale Singletons; Injektion via `ref.read()`/`ref.watch()`.

## Datenmodell (Firestore)
- Sammlung: `users/{uid}/days/{YYYY-MM-DD}`
  - Felder: Morgen/Abend/Planung (Strings, Ratings, Listen für Ziele/Todos).
  - Serverseitige Timestamps für `updatedAt`.

## Speichern & Debounce
- UI triggert Updates über Provider (z. B. `updateDayFieldProvider`).
- Debounce in `DayScreen` bündelt Eingaben, vergleicht mit Cache und speichert nur Änderungen.

## Fehlerbehandlung
- Snackbar bei Erfolg/Fehler.
- Defensive Reads: Nullsafe Pfad‑Zugriffe aus Snapshots.

## Tests
- Unit: Provider/Services isoliert (Mock Firestore/HTTP).
- Widget: Kritische Screens (z. B. `DayScreen`) mit Golden/Interaction Tests.

## Build & Deploy
- CI: Format/Analyze/Test, Coverage als Artefakt.
- Web: GitHub Pages – Build via Workflow, PR‑Previews und Deploy auf `main`.

