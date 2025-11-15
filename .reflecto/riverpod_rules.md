# Reflecto Riverpod Rules

## Provider-Typen
- StateNotifierProvider: komplexe Logik
- FutureProvider: einmaliges Laden
- StreamProvider: Firestore Streams
- Provider: reine Berechnung

## Regeln
1. Keine Provider im UI erstellen
2. Provider gehören nach /features/<feature>/providers/
3. StateNotifier <-> Logic entkoppeln
4. Selector verwenden, um Rebuilds zu reduzieren

Best Practices:
- Typisierte Modelle
- AsyncValue korrekt behandeln

