import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show DateTimeRange;

import '../models/journal_entry.dart';
import '../models/user_model.dart';
import 'user/firestore_user_service.dart';
import 'entry/firestore_entry_service.dart';
import 'planning/firestore_planning_service.dart';
import 'streak/firestore_streak_service.dart';
import 'weekly/firestore_weekly_service.dart';
import 'utils/firestore_date_utils.dart';

/// Zentrale Firestore-Serviceklasse (Singleton) für Journal-Operationen
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();
  factory FirestoreService() => instance;

  // Nutzer-Collection wird nun durch die spezialisierten Services verwendet.

  DocumentReference<Map<String, dynamic>> entryRef(String uid, DateTime date) =>
      FirestoreEntryService.instance.entryRef(uid, date);

  /// Erstellt ein leeres Dokument für den Tag, wenn nicht vorhanden.
  Future<void> ensureEntry(String uid, DateTime date) async {
    return FirestoreEntryService.instance.ensureEntry(uid, date);
  }

  /// Alias für Bestandscode.
  Future<void> createEmptyEntry(String uid, DateTime date) =>
      FirestoreEntryService.instance.createEmptyEntry(uid, date);

  /// Echtzeit-Stream eines Tagebucheintrags (kann null liefern, wenn nicht vorhanden).
  Stream<JournalEntry?> getDailyEntry(String uid, DateTime date) {
    return FirestoreEntryService.instance.getDailyEntry(uid, date);
  }

  /// Partielles Update eines Feldes per Pfad (dot-path), setzt updatedAt.
  Future<void> updateField(
    String uid,
    DateTime date,
    String fieldPath,
    dynamic value,
  ) async {
    return FirestoreEntryService.instance.updateField(
      uid,
      date,
      fieldPath,
      value,
    );
  }

  /// Planung des Vortags abrufen.
  Future<Map<String, dynamic>?> getPlanningOfPreviousDay(
    String uid,
    DateTime date,
  ) async {
    return FirestorePlanningService.instance.getPlanningOfPreviousDay(
      uid,
      date,
    );
  }

  /// Aktualisiert den Abhak-Status eines Eintrags (To-do oder Ziel) in der Abendreflexion.
  /// Unterstützt beide: `evening.todosCompletion.$index` und `evening.goalsCompletion.$index`
  Future<void> _updateCompletionStatus(
    String uid,
    DateTime date,
    String fieldPath,
    int index,
    bool value,
  ) async {
    final field = '$fieldPath.$index';
    await updateField(uid, date, field, value);
  }

  /// Aktualisiert den Abhak-Status eines To-do-Eintrags in der Abendreflexion.
  Future<void> updateTodoCompletion(
    String uid,
    DateTime date,
    int index,
    bool value,
  ) => _updateCompletionStatus(
    uid,
    date,
    'evening.todosCompletion',
    index,
    value,
  );

  /// Aktualisiert den Abhak-Status eines Ziel-Eintrags (Goals) in der Abendreflexion.
  Future<void> updateGoalCompletion(
    String uid,
    DateTime date,
    int index,
    bool value,
  ) => _updateCompletionStatus(
    uid,
    date,
    'evening.goalsCompletion',
    index,
    value,
  );

  /// Markiert die Abendreflexion als abgeschlossen und aktualisiert den Streak.
  Future<void> markEveningCompletedAndUpdateStreak(
    String uid,
    DateTime date,
  ) async {
    return FirestoreStreakService.instance.markEveningCompletedAndUpdateStreak(
      uid,
      date,
    );
  }

  // -------------------------------------------------
  // Zusätzliche bestehende Helfer (Kompatibilität)
  // -------------------------------------------------

  // Datum-/Wochen-Helfer wurden in `FirestoreDateUtils` ausgelagert.
  static String weekIdFrom(DateTime d) => FirestoreDateUtils.weekIdFrom(d);
  static DateTimeRange weekRangeFrom(DateTime d) =>
      FirestoreDateUtils.weekRangeFrom(d);

  Future<List<JournalEntry>> fetchWeekEntries(
    String uid,
    DateTime anyDayInWeek,
  ) async {
    return FirestoreEntryService.instance.fetchWeekEntries(uid, anyDayInWeek);
  }

  Future<void> saveWeeklyReflection(
    String uid,
    String weekId,
    Map<String, dynamic> data,
  ) async {
    return FirestoreWeeklyService.instance.saveWeeklyReflection(
      uid,
      weekId,
      data,
    );
  }

  Stream<Map<String, dynamic>?> weeklyReflectionStream(
    String uid,
    String weekId,
  ) {
    return FirestoreWeeklyService.instance.weeklyReflectionStream(uid, weekId);
  }

  Future<void> saveUserData(AppUser user) async {
    return FirestoreUserService.instance.saveUserData(user);
  }

  Future<AppUser?> getUser(String uid) async {
    return FirestoreUserService.instance.getUser(uid);
  }

  /// Verschiebt einen Eintrag aus der heutigen Planung (goals/todos)
  /// in die Planung des nächsten Tages. Nutzt eine Firestore-Transaction
  /// und bevorzugt leere Slots, ansonsten wird angehängt.
  Future<void> movePlanningItemToNextDay(
    String uid,
    DateTime date, {
    required bool isGoal,
    required int index,
  }) async {
    return FirestorePlanningService.instance.movePlanningItemToNextDay(
      uid,
      date,
      isGoal: isGoal,
      index: index,
    );
  }

  /// Verschiebt ein spezifisches Planungselement (per Textvergleich, trim)
  /// von einem Datum zu einem anderen. Nutzt eine Transaktion, vermeidet
  /// Duplikate am Ziel und erhält leere Slots, die ans Ende verschoben werden.
  Future<void> moveSpecificPlanningItem({
    required String uid,
    required DateTime from,
    required DateTime to,
    required bool isGoal,
    required String itemText,
  }) async {
    return FirestorePlanningService.instance.moveSpecificPlanningItem(
      uid: uid,
      from: from,
      to: to,
      isGoal: isGoal,
      itemText: itemText,
    );
  }

  /// Einmalige Datenbereinigung: entfernt Duplikate (trim-basierend)
  /// in planning.goals / planning.todos in allen Tagebucheinträgen
  /// eines Nutzers. Leere Slots bleiben erhalten, werden aber ans
  /// Ende verschoben.
  Future<int> dedupeAllPlanningForUser(String uid) async {
    return FirestorePlanningService.instance.dedupeAllPlanningForUser(uid);
  }

  // (erledigt) planning-spezifische Hilfsfunktionen wurden ausgelagert
}
