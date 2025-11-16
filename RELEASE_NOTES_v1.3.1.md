# Release Notes v1.3.1

**Veröffentlicht:** 16. November 2025  
**Build:** 1.3.1+2

## 🎯 Highlights

Diese Version bringt substanzielle Verbesserungen für Performance, Datenintegrität und UI-Konsistenz – alles unter der Haube, ohne Breaking Changes.

### Datenmodell & Performance (#52)

**Typisierte Firestore-Zugriffe**
- Entries, Users und WeeklyReflections nutzen jetzt `.withConverter<T>` für type-safe Streams
- Weniger Map-Casting, klarere Datenflüsse, weniger Fehlerquellen

**Timestamps & Tracking**
- `createdAt` wird bei erstmaligem Anlegen eines Tageseintrags gesetzt
- `updatedAt` konsequent via `serverTimestamp()` für korrekte Server-Zeit

**Atomare Transaktionen**
- Streak-Update (Abendabschluss + Zähler) läuft in einer Transaction
- Eliminiert Race Conditions und garantiert Konsistenz

**Batch-Writes**
- Maintenance-Dedupe nutzt Batches (max 450 Ops/Commit)
- Deutlich performanter bei großen Datenmengen

**WeeklyReflection-Model**
- Neue typisierte Klasse mit Unit-Test
- Saubere Trennung von Lese-/Schreiblogik

### UI & Design-Konsistenz (#53)

**Spacing-Tokens flächendeckend**
- Alle Screens/Widgets nutzen `ReflectoSpacing` (s4/s8/s12/s16/s24)
- Keine Magic Numbers mehr im UI-Code
- Einfachere Theme-Anpassungen in Zukunft

**Theme-TextStyles**
- Titel/Labels über `Theme.of(context).textTheme.*`
- Konsistente Typografie über die gesamte App
- Hell-/Dunkel-Modus automatisch adaptiert

**Aktualisierte Komponenten**
- Screens: Auth, Settings, Week, Home
- Week-Feature: Stats, Navigation, Export, AI-Analysis
- Day-Feature: Emoji-Bar, Labeled-Field, Streak, Shell, Evening-Section
- Settings: Version-Info, Profil

### Riverpod-Optimierung (#51)

- Provider mit dynamischen Parametern nutzen `autoDispose`
- Automatische Bereinigung nicht mehr benötigter Provider-Instanzen
- Reduzierter Speicherverbrauch bei Navigation zwischen Tagen/Wochen
- Keine Memory Leaks durch veraltete Stream-Subscriptions

### Dependencies

- `package_info_plus`: 8.3.1 → 9.0.0

## 🔍 Technische Details

**Validierung**
- ✅ `flutter analyze`: Keine Befunde
- ✅ Unit-Tests erweitert (WeeklyReflection-Model)
- ✅ Rückwärtskompatibel: Schema/Felder unverändert

**Code-Qualität**
- Neue Lint-Regel für UI-Konsistenz (Super-Parameters, Closure-Types)
- Deutsche Kommentare durchgängig beibehalten
- STYLEGUIDE präzisiert mit Token-/Theme-Guidelines

**Dokumentation**
- `DATA_MODEL.md`: Aktualisiert mit Schema-Änderungen
- `CHANGELOG.md`: Vollständige v1.3.1-Notes

## 📦 Migration

Keine Aktion erforderlich – alle Änderungen sind rückwärtskompatibel.

## 🐛 Bekannte Einschränkungen

Keine neuen bekannten Issues in dieser Version.

## 🚀 Nächste Schritte

- Weitere UI-Screens auf Token-System umstellen
- Performance-Monitoring in Production
- Golden-Tests für UI-Komponenten

---

**Vollständige Änderungen:** Siehe [CHANGELOG.md](CHANGELOG.md)  
**Issues:** [#51](https://github.com/AlexBuchnerTeacher/reflecto/issues/51), [#52](https://github.com/AlexBuchnerTeacher/reflecto/issues/52), [#53](https://github.com/AlexBuchnerTeacher/reflecto/issues/53)
