# Reflecto – Architekturüberblick

**Version:** v1.5.0  
**Ziel:** Schlanke, testbare Struktur für Flutter + Firebase + Riverpod

---

## 🏗️ Architektur-Ebenen

### 1. UI Layer (`lib/screens`, `lib/widgets`, `lib/features/*/widgets`)
Stellt Views und Widgets bereit, konsumiert State via Riverpod.

**Hauptscreens:**
- `DayScreen`: Tagesreflexion (Morgen/Abend/Planung)
- `WeekScreen`: Wochenübersicht mit Statistiken und AI-Analyse
- `HabitScreen`: Habit-Tracking mit CRUD und Fortschrittsanzeige
- `SettingsScreen`: User-Einstellungen und Profil

**Feature-Organisation:**
- `lib/features/day/`: Day-spezifische Widgets (MorningSection, EveningSection, etc.)
- `lib/features/week/`: Week-spezifische Widgets (WeekHeroCard, WeekRadialStats, etc.)
- `lib/features/habits/`: Habit-spezifische Widgets (HabitCard, HabitDialog)

### 2. State Management (`lib/providers`)
Riverpod Provider für reaktiven State und Business-Logik.

**Provider-Kategorien:**
- **Auth:** `authStateChangesProvider`, `userIdProvider`
- **Entries:** `entryProvider`, `updateDayFieldProvider`
- **Weekly:** `weeklyReflectionProvider`, `weeklyStatsProvider`
- **Habits:** `habitsProvider`, `habitNotifierProvider`, `habitsSyncStatusProvider`
- **Templates:** `habitTemplatesProvider`
- **Meals:** `mealsProvider`, `mealNotifierProvider`

**Pattern:**
- `StreamProvider` für Firestore-Streams
- `AsyncNotifier` für CRUD-Operationen (habits, meals)
- `Provider` für Services und Utilities

### 3. Services (`lib/services`)
Firebase/HTTP Zugriffe und reine Seiteneffekte.

**Core Services:**
- `HabitService`: CRUD, Streak-Berechnung, Scheduling-Logik
- `HabitTemplateService`: Template-Management und Seeding
- `HabitMigration`: Batch-Migration für Kategorie-Upgrades
- `ExportImportService`: JSON/Markdown-Export für Wochenanalysen
- `FirestoreService`: (Legacy) Basis-CRUD für Entries

**Service-Prinzipien:**
- Typisierte Collections via `withConverter()`
- Defensive Null-Checks
- Server-Timestamps für `updatedAt`

### 4. Models (`lib/models`)
Datenklassen mit (de-)Serialisierung.

**Hauptmodelle:**
- `Habit`: title, category, frequency, streak, completedDates
- `HabitTemplate`: Vorlagen für Habits
- `JournalEntry`: Tageseinträge (planning, morning, evening, ratings)
- `WeeklyReflection`: Wochenmotto, Zusammenfassung, AI-Analyse
- `MealLog`: Essenslog (breakfast, lunch, dinner)

---

## 🔄 State Management (Riverpod)

### Provider-Architektur
```dart
// Service-Provider (singleton)
final habitServiceProvider = Provider<HabitService>((ref) => HabitService());

// Stream-Provider (reaktiv)
final habitsProvider = StreamProvider.autoDispose<List<Habit>>((ref) {
  final uid = ref.watch(userIdProvider);
  final service = ref.watch(habitServiceProvider);
  return service.watchHabits(uid);
});

// AsyncNotifier (CRUD)
class HabitNotifier extends AutoDisposeAsyncNotifier<void> {
  Future<String?> createHabit({...}) async { ... }
  Future<void> updateHabit({...}) async { ... }
  Future<void> deleteHabit(String habitId) async { ... }
}
```

### Dependency Flow
1. UI konsumiert Provider via `ref.watch()` (reaktiv) oder `ref.read()` (einmalig)
2. Provider nutzen Services für Firestore-Zugriffe
3. Services verwenden Models für Serialisierung
4. State-Updates triggern automatisch UI-Rebuilds

---

## 💾 Datenmodell (Firestore)

### Collections

#### `entries/{yyyy-MM-dd}`
Tageseinträge mit Morgen-/Abend-Reflexion und Planung.

**Felder:**
- `planning`: goals (3 Slots), todos (3 Slots), reflection, notes
- `morning`: mood, goodThing, focus
- `evening`: good, learned, improve, gratitude, todosCompletion, goalsCompletion
- `ratingsMorning`: mood, energy, focus (1-5)
- `ratingsEvening`: mood, energy, happiness (1-5)
- `migratedV1`: bool (Slot-Normalisierung)
- `createdAt`, `updatedAt`: Timestamp

#### `weekly_reflections/{yyyy-ww}`
Wochenreflexionen mit AI-Analyse.

**Felder:**
- `motto`: String? (Wochenmotto)
- `summaryText`: String? (Zusammenfassung)
- `aiAnalysisText`: String? (ChatGPT Markdown-Analyse)
- `aiAnalysis`: Map? (Strukturierte Daten)
- `updatedAt`: Timestamp

#### `users/{uid}/habits/{habitId}`
Gewohnheiten mit Streak-Tracking.

**Felder:**
- `title`, `category`, `color`: String
- `frequency`: "daily" | "weekly_days" | "weekly_target" | "irregular"
- `weekdays`: List<int>? (1=Mo ... 7=So)
- `weeklyTarget`: int? (Ziel-Tage/Woche)
- `reminderTime`: String? (HH:mm)
- `sortIndex`: int? (Reihenfolge)
- `streak`: int (Tage in Folge)
- `completedDates`: List<String> (yyyy-MM-dd)
- `createdAt`, `updatedAt`: Timestamp

#### `habit_templates/{templateId}`
Globale Habit-Vorlagen (40+ kuratierte Templates in 8 Kategorien).

**Felder:**
- `id`, `title`, `category`, `color`: String
- `frequency`, `weekdays`, `weeklyTarget`, `reminderTime`: (wie Habit)

#### `users/{uid}/meals/{yyyy-MM-dd}`
Essenslog pro Tag.

**Felder:**
- `breakfast`, `lunch`, `dinner`: Map mit `isDone` (bool) und `notes` (String?)

Siehe [DATA_MODEL.md](DATA_MODEL.md) für Details.

---

## 🔁 Sync & Persistence

### Firestore-Sync
- **Offline-First:** Firestore-Persistence aktiviert
- **Optimistic Updates:** UI zeigt sofort Änderungen, Sync im Hintergrund
- **Pending Writes:** `habitsSyncStatusProvider` prüft `metadata.hasPendingWrites`
- **Conflict Resolution:** Last-Write-Wins via `FieldValue.serverTimestamp()`

### Debounce & Caching
- **DayScreen:** TextFields debounced (300ms), Vergleich mit Cache vor Save
- **WeekScreen:** Statistiken gecacht, nur bei Datums-Wechsel neu berechnet
- **HabitScreen:** Toggle sofort, Streak-Update im Service

---

## 🧪 Tests

### Bestehende Tests
- `test/habit_model_test.dart`: Habit Model Serialisierung
- `test/streak_providers_test.dart`: Streak-Logik (veraltet, Refactor needed)
- `test/weekly_reflection_model_test.dart`: WeeklyReflection Serialisierung
- `test/widget_test.dart`: Smoke Test (App startet)

### Target: 50% Coverage (v1.5.0)
- **Unit Tests:** Streak-Berechnung, Scheduling-Logik, Sorting
- **Widget Tests:** HabitCard, DayScreen Sections
- **Integration Tests:** Habit CRUD Flow

---

## 🚀 Build & Deploy

### CI/CD (GitHub Actions)
- **build.yml:** Lint, Analyze, Test auf PRs
- **gh-pages.yml:** Flutter Web Build & Deploy zu GitHub Pages
- **7-Day Carousel:** Automatische Cleanup alter Deployments

### Deployment
- **Web:** GitHub Pages (`https://alexbuchnerteacher.github.io/reflecto/`)
- **Mobile:** (Future) Play Store / App Store via Fastlane

### Release-Prozess
1. Feature-Branch → PR mit CI-Checks
2. Merge zu `main` triggert GitHub Pages Deploy
3. Manual Release Tags (v1.x.x) mit Changelog

---

## 🎨 UI/UX Patterns

### Design System
- **Theme:** Material 3 mit Custom Tokens (`lib/theme/tokens.dart`)
- **Spacing:** ReflectoSpacing (s4, s8, s12, s16, s20, s24, s32)
- **Colors:** Reflecto Brand Colors (Primary, Container, Surface)
- **Typography:** Reflecto Text Styles (displayLarge, titleMedium, bodySmall)

### Reusable Widgets
- `ReflectoCard`: Konsistente Card-Darstellung
- `RatingsRow`: 1-5 Sterne-Rating
- `ReflectoSparkline`: 7-Tage Sparkline
- `WeekHeroCard`: Circular Progress mit Statistiken
- `HabitCard`: Habit-Darstellung mit Checkbox, Streak, Fortschritt

### Navigation
- `HomeScreen` mit BottomNavigationBar (Tag, Woche, Habits, Einstellungen)
- `AutoDispose` Provider für Memory-Optimierung
- `GoRouter` (optional für Future Deep-Linking)

---

## 🔐 Security & Best Practices

### Firebase Security
- **Firestore Rules:** User-spezifische Collections (nur eigene Daten lesbar/schreibbar)
- **Auth:** Firebase Auth mit Google Sign-In
- **No Secrets in Code:** API-Keys in `.env` (nicht committed)

### Code Quality
- **Linting:** `analysis_options.yaml` mit strict rules
- **Formatting:** `dart format` in Pre-Commit Hook
- **No Deprecated APIs:** Migration von `withOpacity` → `withValues`

### Performance
- **AutoDispose:** Provider automatisch aufräumen bei Screen-Wechsel
- **Efficient Queries:** `orderBy` + `limit` für große Collections
- **Image Optimization:** (Future) Web-optimierte Assets

---

## 📦 Dependencies

### Core
- `flutter`: ^3.24.0
- `firebase_core`, `firebase_auth`, `cloud_firestore`
- `flutter_riverpod`: ^2.6.1

### UI
- `google_fonts`: Roboto Flex
- `intl`: Datum-Formatierung
- `flutter_markdown`: AI-Analyse Rendering

### Dev
- `flutter_test`
- `flutter_lints`

---

## 🗺️ Future Roadmap

### v1.6.0 (Productivity MVP)
- Habit-Insights (Mini-Analytics)
- Smart Habits Auto-Priorisierung
- Weekly Review (Snapshot Sonntag 20:00)

### v1.7.0 (Scaling & UX)
- Push Notifications (#47)
- Offline-Strategy
- Crashlytics Integration

### v2.0.0 (Vision)
- Release Automation
- Community Features
- ML-based Insights

Siehe [ROADMAP.md](../ROADMAP.md) für Details.

