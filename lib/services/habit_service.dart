import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/habit.dart';
import '../models/habit_priority.dart';

/// Service für Habit-Management: CRUD, Streak-Berechnung, Firestore-Sync
class HabitService {
  final FirebaseFirestore _firestore;

  HabitService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Typisierte Habit-Collection für einen User
  CollectionReference<Habit> _habitsCollection(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .withConverter<Habit>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data();
            if (data == null) {
              throw StateError('Habit data is null for ${snapshot.id}');
            }
            return Habit.fromMap(snapshot.id, data);
          },
          toFirestore: (habit, _) => habit.toMap(),
        );
  }

  /// Stream aller Habits eines Users (sortiert nach createdAt)
  Stream<List<Habit>> watchHabits(String uid) {
    return _habitsCollection(uid)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Stream für Sync-Status (true = synced, false = pending writes)
  Stream<bool> watchHabitsSyncStatus(String uid) {
    return _habitsCollection(uid)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => !snapshot.metadata.hasPendingWrites);
  }

  /// Einzelnes Habit abrufen
  Future<Habit?> getHabit(String uid, String habitId) async {
    final doc = await _habitsCollection(uid).doc(habitId).get();
    return doc.data();
  }

  /// Neues Habit anlegen
  Future<String> createHabit({
    required String uid,
    required String title,
    required String category,
    required String color,
    required String frequency,
    String? reminderTime,
    List<int>? weekdays,
    int? weeklyTarget,
    int? sortIndex,
  }) async {
    final now = DateTime.now();
    final habit = Habit(
      id: '', // wird von Firestore generiert
      title: title,
      category: category,
      color: color,
      frequency: frequency,
      weekdays: weekdays,
      weeklyTarget: weeklyTarget,
      reminderTime: reminderTime,
      sortIndex: sortIndex,
      streak: 0,
      completedDates: [],
      createdAt: now,
      updatedAt: now,
    );

    final docRef = await _habitsCollection(uid).add(habit);
    return docRef.id;
  }

  /// Habit aktualisieren
  Future<void> updateHabit({
    required String uid,
    required String habitId,
    String? title,
    String? category,
    String? color,
    String? frequency,
    String? reminderTime,
    List<int>? weekdays,
    int? weeklyTarget,
    int? sortIndex,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (title != null) updates['title'] = title;
    if (category != null) updates['category'] = category;
    if (color != null) updates['color'] = color;
    if (frequency != null) updates['frequency'] = frequency;
    if (reminderTime != null) {
      updates['reminderTime'] = reminderTime;
    }
    if (weekdays != null) updates['weekdays'] = weekdays;
    if (weeklyTarget != null) updates['weeklyTarget'] = weeklyTarget;
    if (sortIndex != null) updates['sortIndex'] = sortIndex;

    await _habitsCollection(uid).doc(habitId).update(updates);
  }

  /// Gibt Wochenfenster (Montag 00:00 bis Sonntag 23:59:59.999) für ein Datum zurück
  ({DateTime start, DateTime end}) getWeekWindow(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final weekday = d.weekday; // 1=Mo ... 7=So
    final start = d.subtract(Duration(days: weekday - 1));
    final end = start.add(const Duration(days: 6));
    return (start: start, end: end);
  }

  /// Prüft, ob ein Habit an einem Datum planmäßig ist
  bool isScheduledOnDate(Habit habit, DateTime date) {
    final freq = habit.frequency;
    if (freq == 'daily') return true;
    if (freq == 'weekly_days' || freq == 'weekly') {
      final wds = habit.weekdays ?? const [];
      return wds.contains(date.weekday);
    }
    if (freq == 'weekly_target') {
      return true; // beliebige Tage in der Woche zulässig
    }
    if (freq == 'irregular') {
      return true; // immer zulässig, kein Plan
    }
    return true;
  }

  /// Anzahl eindeutiger Erledigungs-Tage innerhalb der Woche des angegebenen Datums
  int countCompletionsInWeek(Habit habit, DateTime date) {
    final window = getWeekWindow(date);
    final start = window.start;
    final end = window.end;
    int count = 0;
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final cur = start.add(Duration(days: i));
      if (isCompletedOnDate(habit, cur)) count++;
    }
    return count;
  }

  /// Anzahl erledigter, geplanter Tage innerhalb der Woche (nur weekly_days relevant)
  int countPlannedCompletionsInWeek(Habit habit, DateTime date) {
    final window = getWeekWindow(date);
    final start = window.start;
    final end = window.end;
    int count = 0;
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final cur = start.add(Duration(days: i));
      if (isScheduledOnDate(habit, cur) && isCompletedOnDate(habit, cur)) {
        count++;
      }
    }
    return count;
  }

  /// Geplante Tagesanzahl für die Woche je Habit-Typ
  int plannedDaysInWeek(Habit habit) {
    final freq = habit.frequency;
    if (freq == 'daily') return 7;
    if (freq == 'weekly_days' || freq == 'weekly') {
      return habit.weekdays?.length ?? 0;
    }
    if (freq == 'weekly_target') {
      return habit.weeklyTarget ?? 0;
    }
    // irregular: kein Nenner
    return 0;
  }

  /// Habit löschen
  Future<void> deleteHabit(String uid, String habitId) async {
    await _habitsCollection(uid).doc(habitId).delete();
  }

  /// Habit für ein bestimmtes Datum als erledigt markieren
  ///
  /// Berechnet automatisch die neue Streak-Länge:
  /// - Wenn vorheriger Tag auch completed: streak++
  /// - Wenn Lücke: streak = 1
  Future<void> markCompleted({
    required String uid,
    required String habitId,
    required DateTime date,
  }) async {
    final dateStr = _formatDate(date);
    final habit = await getHabit(uid, habitId);
    if (habit == null) return;

    // Bereits completed? Dann abbrechen
    if (habit.completedDates.contains(dateStr)) return;

    final updatedDates = [...habit.completedDates, dateStr]..sort();
    final newStreak = _calculateStreak(updatedDates, date);

    await _habitsCollection(uid).doc(habitId).update({
      'completedDates': updatedDates,
      'streak': newStreak,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Habit für ein Datum als nicht erledigt markieren (uncomplete)
  Future<void> markUncompleted({
    required String uid,
    required String habitId,
    required DateTime date,
  }) async {
    final dateStr = _formatDate(date);
    final habit = await getHabit(uid, habitId);
    if (habit == null) return;

    if (!habit.completedDates.contains(dateStr)) return;

    final updatedDates =
        habit.completedDates.where((d) => d != dateStr).toList()..sort();
    final newStreak = _calculateStreak(updatedDates, date);

    await _habitsCollection(uid).doc(habitId).update({
      'completedDates': updatedDates,
      'streak': newStreak,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Prüft, ob Habit für ein bestimmtes Datum completed ist
  bool isCompletedOnDate(Habit habit, DateTime date) {
    final dateStr = _formatDate(date);
    return habit.completedDates.contains(dateStr);
  }

  /// Formatiert Datum zu "yyyy-MM-dd" String
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Berechnet aktuelle Streak-Länge basierend auf completedDates
  ///
  /// Logik: Zählt rückwärts von [referenceDate], wie viele aufeinanderfolgende
  /// Tage completed sind. Bricht bei erster Lücke ab.
  int _calculateStreak(List<String> completedDates, DateTime referenceDate) {
    if (completedDates.isEmpty) return 0;

    final sortedDates = completedDates.toList()..sort();
    final refStr = _formatDate(referenceDate);

    // Wenn Referenzdatum nicht completed ist, Streak = 0
    if (!sortedDates.contains(refStr)) {
      // Ausnahme: Wenn gestern completed war, zählt das als aktuelle Streak
      final yesterday = referenceDate.subtract(const Duration(days: 1));
      final yesterdayStr = _formatDate(yesterday);
      if (!sortedDates.contains(yesterdayStr)) {
        return 0;
      }
      // Ansonsten zählen wir ab gestern
      return _countConsecutiveDaysBackwards(sortedDates, yesterday);
    }

    return _countConsecutiveDaysBackwards(sortedDates, referenceDate);
  }

  /// Zählt aufeinanderfolgende Tage rückwärts ab [startDate]
  int _countConsecutiveDaysBackwards(
    List<String> sortedDates,
    DateTime startDate,
  ) {
    int count = 0;
    DateTime current = startDate;

    while (true) {
      final dateStr = _formatDate(current);
      if (sortedDates.contains(dateStr)) {
        count++;
        current = current.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return count;
  }

  /// Berechnet Completion-Rate für eine Zeitspanne (z.B. letzte 7 Tage)
  ///
  /// Gibt Prozentwert zurück (0.0 - 1.0)
  double getCompletionRate({
    required Habit habit,
    required int days,
    DateTime? endDate,
  }) {
    final end = endDate ?? DateTime.now();
    final start = end.subtract(Duration(days: days - 1));

    int completedCount = 0;
    for (int i = 0; i < days; i++) {
      final date = start.add(Duration(days: i));
      if (isCompletedOnDate(habit, date)) {
        completedCount++;
      }
    }

    return completedCount / days;
  }

  /// Berechnet Smart Priority Score für ein Habit
  ///
  /// Score-Formel basiert auf:
  /// - Streak-Länge (0-30 Punkte): Längere Streaks = höhere Priorität
  /// - 7-Tage-Konsistenz (0-40 Punkte): Regelmäßige Completion = höher
  /// - Skip-Count letzte 7 Tage (0-30 Punkte): Weniger Skips = höher
  ///
  /// Gesamt: 0-100 Punkte
  /// - High (🔥): >= 70
  /// - Medium (⬆️): >= 40
  /// - Low (⬇️): < 40
  HabitPriorityScore calculateHabitPriority(
    Habit habit, {
    DateTime? referenceDate,
  }) {
    final date = referenceDate ?? DateTime.now();
    double score = 0.0;

    // 1. Streak-Komponente (0-30 Punkte)
    // Längere Streaks erhöhen Priorität (Momentum beibehalten)
    final streakScore = (habit.streak / 10).clamp(0.0, 3.0) * 10;
    score += streakScore;

    // 2. Konsistenz letzte 7 Tage (0-40 Punkte)
    // Hohe Completion-Rate = hohe Priorität
    final completionRate = getCompletionRate(
      habit: habit,
      days: 7,
      endDate: date,
    );
    final consistencyScore = completionRate * 40;
    score += consistencyScore;

    // 3. Skip-Analyse letzte 7 Tage (0-30 Punkte)
    // Zähle geplante aber nicht erledigte Tage
    int skippedDays = 0;
    int scheduledDays = 0;
    for (int i = 0; i < 7; i++) {
      final checkDate = date.subtract(Duration(days: i));
      if (isScheduledOnDate(habit, checkDate)) {
        scheduledDays++;
        if (!isCompletedOnDate(habit, checkDate)) {
          skippedDays++;
        }
      }
    }

    // Je weniger Skips, desto höher der Score
    final skipPenalty = scheduledDays > 0 ? (skippedDays / scheduledDays) : 0.0;
    final skipScore = (1.0 - skipPenalty) * 30;
    score += skipScore;

    // Score auf 0-100 clampen
    score = score.clamp(0.0, 100.0);

    // Prioritätslevel bestimmen
    final priority = score >= 70
        ? HabitPriority.high
        : score >= 40
            ? HabitPriority.medium
            : HabitPriority.low;

    return HabitPriorityScore(priority: priority, score: score);
  }

  /// Sortiert Habits nach Smart Priority (höchste zuerst)
  List<Habit> sortHabitsByPriority(
    List<Habit> habits, {
    DateTime? referenceDate,
  }) {
    final habitScores = <({Habit habit, double score})>[];

    for (final habit in habits) {
      final priorityScore = calculateHabitPriority(
        habit,
        referenceDate: referenceDate,
      );
      habitScores.add((habit: habit, score: priorityScore.score));
    }

    // Sortiere nach Score (höchste zuerst)
    habitScores.sort((a, b) => b.score.compareTo(a.score));

    return habitScores.map((e) => e.habit).toList();
  }

  /// Sortiert Habits nach Custom Order (sortIndex) und Status
  ///
  /// Sortierlogik:
  /// 1. Unerledigte Habits nach sortIndex (aufsteigend)
  /// 2. Erledigte Habits nach sortIndex (aufsteigend), aber am Ende
  ///
  /// Habits ohne sortIndex werden nach createdAt einsortiert
  List<Habit> sortHabitsByCustomOrder(
    List<Habit> habits, {
    required DateTime today,
  }) {
    final incomplete = <Habit>[];
    final completed = <Habit>[];

    for (final habit in habits) {
      if (isCompletedOnDate(habit, today)) {
        completed.add(habit);
      } else {
        incomplete.add(habit);
      }
    }

    // Sortiere jeweils nach sortIndex (oder createdAt als Fallback)
    incomplete.sort((a, b) {
      final aIndex = a.sortIndex ?? 999999;
      final bIndex = b.sortIndex ?? 999999;
      if (aIndex != bIndex) return aIndex.compareTo(bIndex);
      return a.createdAt.compareTo(b.createdAt);
    });

    completed.sort((a, b) {
      final aIndex = a.sortIndex ?? 999999;
      final bIndex = b.sortIndex ?? 999999;
      if (aIndex != bIndex) return aIndex.compareTo(bIndex);
      return a.createdAt.compareTo(b.createdAt);
    });

    return [...incomplete, ...completed];
  }

  /// Aktualisiert sortIndex für mehrere Habits (Batch-Operation)
  ///
  /// Wird nach Drag & Drop aufgerufen um neue Reihenfolge zu speichern
  Future<void> reorderHabits({
    required String uid,
    required List<({String habitId, int sortIndex})> updates,
  }) async {
    final batch = _firestore.batch();

    for (final update in updates) {
      final docRef = _habitsCollection(uid).doc(update.habitId);
      batch.update(
        docRef.withConverter(
          fromFirestore: (_, __) => throw UnimplementedError(),
          toFirestore: (_, __) => {},
        ),
        {
          'sortIndex': update.sortIndex,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
  }

  /// Ermittelt den höchsten sortIndex in einer Liste von Habits
  ///
  /// Wird beim Erstellen neuer Habits verwendet um diese ans Ende zu setzen
  int getMaxSortIndex(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    return habits.map((h) => h.sortIndex ?? 0).reduce((a, b) => a > b ? a : b);
  }
}
