# Reflecto Coding Guidelines

## Core Rules
- Single Responsibility auf File-Ebene
- Feature-based Struktur
- Keine Firestore-Logik im UI
- Keine Businesslogik in Widgets
- Jede Datei erfüllt exakt 1 Rolle

## UI Guidelines
- Max 300 Zeilen
- Nur Darstellung, keine Kalkulationen

## Logic Guidelines
- Max 300 Zeilen
- Enthält Firestore, Aggregation, Entscheidungen
- Reiner Dart ohne BuildContext

## Controller Guidelines
- Keine Logik
- Nur Lifecycle & Text/Fokus-Verwaltung

## Widget Guidelines
- Max 150 Zeilen
- Keine Provider/Firestore-Zugriffe

## Commits
- feat
- fix
- refactor
- structure
- docs

