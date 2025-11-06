import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateTimeRange;

import '../models/journal_entry.dart';
import '../models/user_model.dart';

/// Zentrale Firestore-Serviceklasse (Singleton) für Journal-Operationen
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();
  factory FirestoreService() => instance;

  final CollectionReference<Map<String, dynamic>> _users = FirebaseFirestore
      .instance
      .collection('users');

  DocumentReference<Map<String, dynamic>> entryRef(String uid, DateTime date) {
    return _users.doc(uid).collection('entries').doc(_formatDate(date));
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _formatDate(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';

  /// Erstellt ein leeres Dokument für den Tag, wenn nicht vorhanden.
  Future<void> ensureEntry(String uid, DateTime date) async {
    try {
      final ref = entryRef(uid, date);
      final snap = await ref.get();
      if (!snap.exists) {
        await ref.set({
          'planning': {
            'goals': <String>[],
            'todos': <String>[],
            'reflection': '',
            'notes': '',
          },
          'morning': {'mood': '', 'goodThing': '', 'focus': ''},
          'evening': {
            'good': '',
            'learned': '',
            'improve': '',
            'gratitude': '',
          },
          'ratings': {'focus': null, 'energy': null, 'happiness': null},
          // Back-Compat: Top-Level Ratings für ältere Stellen
          'ratingFocus': null,
          'ratingEnergy': null,
          'ratingHappiness': null,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } on FirebaseException catch (e) {
      debugPrint('Firestore error (ensureEntry): $e');
      rethrow;
    }
  }

  /// Alias für Bestandscode.
  Future<void> createEmptyEntry(String uid, DateTime date) =>
      ensureEntry(uid, date);

  /// Echtzeit-Stream eines Tagebucheintrags (kann null liefern, wenn nicht vorhanden).
  Stream<JournalEntry?> getDailyEntry(String uid, DateTime date) {
    final ref = entryRef(uid, date);
    return ref.snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return JournalEntry.fromMap(snap.id, data);
    });
  }

  /// Partielles Update eines Feldes per Pfad (dot-path), setzt updatedAt.
  Future<void> updateField(
    String uid,
    DateTime date,
    String fieldPath,
    dynamic value,
  ) async {
    final ref = entryRef(uid, date);
    try {
      await ref.update({
        fieldPath: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        // Dokument existiert noch nicht: per set(merge:true) anlegen
        final nested = _mapFromPath(fieldPath, value);
        nested['updatedAt'] = FieldValue.serverTimestamp();
        await ref.set(nested, SetOptions(merge: true));
      } else {
        debugPrint('Firestore error (updateField): $e');
        rethrow;
      }
    }
  }

  /// Planung des Vortags abrufen.
  Future<Map<String, dynamic>?> getPlanningOfPreviousDay(
    String uid,
    DateTime date,
  ) async {
    try {
      final prev = date.subtract(const Duration(days: 1));
      final snap = await entryRef(uid, prev).get();
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      final planning = data['planning'];
      if (planning is Map<String, dynamic>) {
        return {
          'goals': (planning['goals'] is List)
              ? List<String>.from(planning['goals'])
              : <String>[],
          'todos': (planning['todos'] is List)
              ? List<String>.from(planning['todos'])
              : <String>[],
          'reflection': (planning['reflection'] ?? '') as String,
          'notes': (planning['notes'] ?? '') as String,
        };
      }
      return null;
    } on FirebaseException catch (e) {
      debugPrint('Firestore error (getPlanningOfPreviousDay): $e');
      rethrow;
    }
  }

  /// Aktualisiert den Abhak-Status eines To-do-Eintrags in der Abendreflexion.
  Future<void> updateTodoCompletion(
    String uid,
    DateTime date,
    int index,
    bool value,
  ) async {
    final ref = entryRef(uid, date);
    final field = 'evening.todosCompletion.$index';
    try {
      await ref.update({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        final nested = _mapFromPath(field, value);
        nested['updatedAt'] = FieldValue.serverTimestamp();
        await ref.set(nested, SetOptions(merge: true));
      } else {
        debugPrint('Firestore error (updateTodoCompletion): $e');
        rethrow;
      }
    }
  }

  /// Aktualisiert den Abhak-Status eines Ziel-Eintrags (Goals) in der Abendreflexion.
  Future<void> updateGoalCompletion(
    String uid,
    DateTime date,
    int index,
    bool value,
  ) async {
    final ref = entryRef(uid, date);
    final field = 'evening.goalsCompletion.$index';
    try {
      await ref.update({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        final nested = _mapFromPath(field, value);
        nested['updatedAt'] = FieldValue.serverTimestamp();
        await ref.set(nested, SetOptions(merge: true));
      } else {
        debugPrint('Firestore error (updateGoalCompletion): $e');
        rethrow;
      }
    }
  }

  // -------------------------------------------------
  // Zusätzliche bestehende Helfer (Kompatibilität)
  // -------------------------------------------------

  static int _isoWeekNumber(DateTime date) {
    final thursday = date.add(Duration(days: 3 - ((date.weekday + 6) % 7)));
    final firstThursday = DateTime(thursday.year, 1, 4);
    return 1 + ((thursday.difference(firstThursday).inDays) / 7).floor();
  }

  static DateTime _mondayOfWeek(DateTime d) {
    return DateTime(
      d.year,
      d.month,
      d.day,
    ).subtract(Duration(days: (d.weekday + 6) % 7));
  }

  static String weekIdFrom(DateTime d) {
    final thursday = d.add(Duration(days: 3 - ((d.weekday + 6) % 7)));
    final isoYear = thursday.year;
    final week = _isoWeekNumber(d);
    return '$isoYear-${_two(week)}';
  }

  static DateTimeRange weekRangeFrom(DateTime d) {
    final monday = _mondayOfWeek(d);
    final start = DateTime(monday.year, monday.month, monday.day, 0, 0, 0);
    final endBase = monday.add(const Duration(days: 6));
    final end = DateTime(
      endBase.year,
      endBase.month,
      endBase.day,
      23,
      59,
      59,
      999,
    );
    return DateTimeRange(start: start, end: end);
  }

  Future<List<JournalEntry>> fetchWeekEntries(
    String uid,
    DateTime anyDayInWeek,
  ) async {
    try {
      final range = weekRangeFrom(anyDayInWeek);
      final startId = _formatDate(range.start);
      final endId = _formatDate(range.start.add(const Duration(days: 6)));
      final col = _users.doc(uid).collection('entries');
      final snap = await col
          .orderBy(FieldPath.documentId)
          .startAt([startId])
          .endAt([endId])
          .get();
      return snap.docs
          .map((d) => JournalEntry.fromMap(d.id, d.data()))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore error (fetchWeekEntries): $e');
      rethrow;
    }
  }

  Future<void> saveWeeklyReflection(
    String uid,
    String weekId,
    Map<String, dynamic> data,
  ) async {
    try {
      final ref = _users.doc(uid).collection('weekly_reflections').doc(weekId);
      await ref.set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      debugPrint('Firestore error (saveWeeklyReflection): $e');
      rethrow;
    }
  }

  Stream<Map<String, dynamic>?> weeklyReflectionStream(
    String uid,
    String weekId,
  ) {
    final ref = _users.doc(uid).collection('weekly_reflections').doc(weekId);
    return ref.snapshots().map((s) => s.data());
  }

  Future<void> saveUserData(AppUser user) async {
    try {
      final ref = _users.doc(user.uid);
      final snap = await ref.get();
      if (!snap.exists) {
        await ref.set({
          ...user.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await ref.set({
          ...user.toMap(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } on FirebaseException catch (e) {
      debugPrint('Firestore error (saveUserData): $e');
      rethrow;
    }
  }

  Future<AppUser?> getUser(String uid) async {
    try {
      final snap = await _users.doc(uid).get();
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return AppUser.fromMap(data);
    } on FirebaseException catch (e) {
      debugPrint('Firestore error (getUser): $e');
      rethrow;
    }
  }

  /// Hilfsfunktion: baut aus einem Pfad eine verschachtelte Map
  Map<String, dynamic> _mapFromPath(String path, dynamic value) {
    final parts = path.split('.');
    final root = <String, dynamic>{};
    var cur = root;
    for (var i = 0; i < parts.length; i++) {
      final p = parts[i];
      if (i == parts.length - 1) {
        cur[p] = value;
      } else {
        cur = (cur[p] ??= <String, dynamic>{}) as Map<String, dynamic>;
      }
    }
    return root;
  }
}
