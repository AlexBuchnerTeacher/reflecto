# Reflecto Architecture Guide

Reflecto verwendet eine modulare, Feature-basierte Architektur, optimiert für Wartbarkeit, Testbarkeit und hohe Entwicklungsgeschwindigkeit.

## Grundprinzipien
1. Feature-First Struktur unter /lib/features/
2. Trennung von UI, Logik, State und Datenoperationen
3. Keine Business- oder Firestore-Logik in UI-Files
4. Maximale Dateigröße: siehe file_size_limits.md
5. Riverpod als verbindliche State-Management-Basis

## Feature-Ordnerstruktur
lib/features/<feature>/
  ├─ ui/
  ├─ sections/
  ├─ controllers/
  ├─ logic/
  ├─ widgets/
  └─ models/

## Verantwortlichkeiten
UI: Darstellung, keine Datenverarbeitung  
Sections: Teilausschnitte eines Screens  
Logic: Firestore, Aggregation, Entscheidungen  
Controllers: TextEditingController, FocusNodes  
Widgets: Wiederverwendbare UI-Elemente  
Models: Strukturierte Datentypen

## Services
Reiner Datenzugriff, zentrale Abstraktionen.

