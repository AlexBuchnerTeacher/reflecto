Diese PR liefert die Basis für den Habit Tracker (Issue #57, Milestone v1.4.0).

Änderungen
- Datenmodell: Habit (Model + toMap/fromMap)
- Service: HabitService (CRUD, Streams, Streak-/Progress-Logik; Firestore-Converter via withConverter)
- Riverpod: habitServiceProvider, habitsProvider, habitProvider, HabitNotifier (sauberer AsyncState)
- UI: HabitScreen (Fortschrittsübersicht), HabitCard (Toggle heute, Streak), HabitDialog (CRUD)
- Navigation: HomeScreen mit neuem Tab "Habits"
- Lints/Styling: Closure-Parameter ohne Typ, deprecated withOpacity -> withValues

Validierung
- flutter analyze: clean
- flutter test: alle Tests grün (inkl. neuem habit_model_test)

Open Points/Nächste Schritte
- Reminder-Integration (#47) – optional je Habit, Systemanbindung
- Erweiterte Statistiken/Heatmap (v1.5.0)
- Evtl. Feature-Flag für Habits-Tab, falls Goldens stabil gehalten werden sollen

Hinweis
- Diese PR schließt #57 noch nicht vollständig, liefert aber die funktionsfähige Basis.
