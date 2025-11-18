import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateTimeRange;

import '../models/journal_entry.dart';
import '../models/user_model.dart';
import '../models/weekly_reflection.dart';

/// Zentrale Firestore-Serviceklasse (Singleton) für Journal-Operationen
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();
  factory FirestoreService() => instance;

  final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  /// Getypter User-Dokument-Ref.
  DocumentReference<AppUser> _userDocTyped(String uid) {
    return _users.doc(uid).withConverter<AppUser>(
          fromFirestore: (snap, _) => AppUser.fromMap(snap.data() ?? {}),
          toFirestore: (user, _) => user.toMap(),
        );
  }

  DocumentReference<Map<String, dynamic>> entryRef(String uid, DateTime date) {
    return _users.doc(uid).collection('entries').doc(_formatDate(date));
  }

  /// Getypte Entries-Collection mit Konvertern für `JournalEntry`.
  CollectionReference<JournalEntry> _typedEntries(String uid) {
    return _users.doc(uid).collection('entries').withConverter<JournalEntry>(
          fromFirestore: (snap, _) {
            final data = snap.data();
            if (data == null) return JournalEntry.empty(snap.id);
            return JournalEntry.fromMap(snap.id, data);
          },
          toFirestore: (entry, _) => entry.toMap(),
        );
  }

  /// Getypte Weekly-Reflections-Collection.
  CollectionReference<WeeklyReflection> _weeklyReflections(String uid) {
    return _users
        .doc(uid)
        .collection('weekly_reflections')
        .withConverter<WeeklyReflection>(
          fromFirestore: (snap, _) {
            final data = snap.data();
            if (data == null) return WeeklyReflection.fromMap(snap.id, {});
            return WeeklyReflection.fromMap(snap.id, data);
          },
          toFirestore: (wr, _) => wr.toMap(),
        );
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
          'createdAt': FieldValue.serverTimestamp(),
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
    final typed = _typedEntries(uid).doc(_formatDate(date));
    return typed.snapshots().map((snap) => snap.data());
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

  /// Markiert die Abendreflexion als abgeschlossen und aktualisiert den Streak.
  Future<void> markEveningCompletedAndUpdateStreak(
    String uid,
    DateTime date,
  ) async {
    try {
      final todayId = _formatDate(date);
      final yesterday = date.subtract(const Duration(days: 1));
      final yId = _formatDate(yesterday);
      final todayRef = entryRef(uid, date);
      final yRef = entryRef(uid, yesterday);
      final streakRef = _users.doc(uid).collection('stats').doc('streak');

      await FirebaseFirestore.instance.runTransaction((tx) async {
        // 1) Streak lesen (oder Defaults)
        final streakSnap = await tx.get(streakRef);
        final sData = streakSnap.data() ?? <String, dynamic>{};
        final lastDate = sData['lastEntryDate'] as String?;
        final current = (sData['streakCount'] is num)
            ? (sData['streakCount'] as num).toInt()
            : 0;
        final longest = (sData['longestStreak'] is num)
            ? (sData['longestStreak'] as num).toInt()
            : 0;

        // 2) Heutigen Abend als completed setzen (immer)
        tx.set(
            todayRef,
            {
              'evening': {'completed': true},
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));

        // Wenn heute bereits gezählt wurde: nur completed setzen und fertig
        if (lastDate == todayId) {
          return;
        }

        // 3) Prüfe gestriges Completed, nur wenn nötig
        bool yCompleted = false;
        try {
          final ySnap = await tx.get(yRef);
          yCompleted = (ySnap.data()?['evening']?['completed'] == true);
        } catch (_) {
          yCompleted = false;
        }

        // 4) Nächsten Wert bestimmen und schreiben
        final shouldChain = yCompleted && (lastDate == yId || lastDate == null);
        final next = shouldChain ? (current + 1) : 1;
        final nextLongest = next > longest ? next : longest;
        tx.set(
            streakRef,
            {
              'streakCount': next,
              'longestStreak': nextLongest,
              'lastEntryDate': todayId,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
      });
    } on FirebaseException catch (e) {
      debugPrint('Firestore error (markEveningCompletedAndUpdateStreak): $e');
      rethrow;
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
      final col = _typedEntries(uid);
      final snap = await col
          .orderBy(FieldPath.documentId)
          .startAt([startId]).endAt([endId]).get();
      return snap.docs.map((d) => d.data()).toList();
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

  /// Typisierte Speicherung einer wöchentlichen Reflexion.
  /// Setzt `updatedAt` serverseitig, andere Felder werden per Merge geschrieben.
  Future<void> saveWeeklyReflectionModel(
    String uid,
    WeeklyReflection wr,
  ) async {
    try {
      final ref = _users.doc(uid).collection('weekly_reflections').doc(wr.id);
      await ref.set({
        ...wr.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      debugPrint('Firestore error (saveWeeklyReflectionModel): $e');
      rethrow;
    }
  }

  Stream<WeeklyReflection?> weeklyReflectionStream(String uid, String weekId) {
    final ref = _weeklyReflections(uid).doc(weekId);
    return ref.snapshots().map((s) => s.data());
  }

  Future<void> saveUserData(AppUser user) async {
    try {
      final ref = _userDocTyped(user.uid);
      final snap = await ref.get();
      if (!snap.exists) {
        // Create: write only known non-null fields + server timestamps.
        await ref.set(
          AppUser(
            uid: user.uid,
            displayName: user.displayName,
            email: user.email,
            photoUrl: user.photoUrl,
            // createdAt wird serverseitig gesetzt (separates Feld)
          ),
          SetOptions(merge: true),
        );
        await _users.doc(user.uid).set({
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // Update: avoid overwriting createdAt; write only provided non-null fields.
        if (user.displayName != null ||
            user.email != null ||
            user.photoUrl != null) {
          await ref.set(
            AppUser(
              uid: user.uid,
              displayName: user.displayName,
              email: user.email,
              photoUrl: user.photoUrl,
            ),
            SetOptions(merge: true),
          );
        }
        // Always bump lastLoginAt
        await _users.doc(user.uid).set({
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
      final snap = await _userDocTyped(uid).get();
      if (!snap.exists) return null;
      return snap.data();
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

  /// Verschiebt einen Eintrag aus der heutigen Planung (goals/todos)
  /// in die Planung des nächsten Tages. Nutzt eine Firestore-Transaction
  /// und bevorzugt leere Slots, ansonsten wird angehängt.
  Future<void> movePlanningItemToNextDay(
    String uid,
    DateTime date, {
    required bool isGoal,
    required int index,
  }) async {
    List<String> dedupePreserveEmptySlots(List<String> input) {
      final seen = <String>{};
      var emptyCount = 0;
      for (final raw in input) {
        final t = raw.toString().trim();
        if (t.isEmpty) {
          emptyCount++;
          continue;
        }
        if (!seen.contains(t)) {
          seen.add(t);
        }
      }
      // leere Slots ans Ende setzen
      return [...seen, ...List.filled(emptyCount, '')];
    }

    final todayRef = entryRef(uid, date);
    final tomorrowRef = entryRef(uid, date.add(const Duration(days: 1)));
    final field = isGoal ? 'goals' : 'todos';
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final todaySnap = await tx.get(todayRef);
      final todayData = todaySnap.data() ?? <String, dynamic>{};
      final planningToday =
          (todayData['planning'] as Map<String, dynamic>?) ?? {};
      var listToday = List<String>.from(
        planningToday[field] ?? const <String>[],
      );
      // Safety: vorhandene Duplikate/Leerfelder normalisieren
      listToday = dedupePreserveEmptySlots(listToday);
      if (index < 0 || index >= listToday.length) return;
      final item = (listToday.removeAt(index)).toString().trim();
      if (item.isEmpty) return;

      final tomorrowSnap = await tx.get(tomorrowRef);
      final tData = tomorrowSnap.data() ?? <String, dynamic>{};
      final planningTomorrow =
          (tData['planning'] as Map<String, dynamic>?) ?? {};
      var listTomorrow = List<String>.from(
        planningTomorrow[field] ?? const <String>[],
      );
      // Safety: Duplikate/Leerfelder normalisieren
      listTomorrow = dedupePreserveEmptySlots(listTomorrow);
      final alreadyThere = listTomorrow.any((e) => e.toString().trim() == item);
      if (!alreadyThere) {
        // Finde ersten leeren Slot
        final emptyIdx = listTomorrow.indexWhere(
          (e) => (e.toString().trim()).isEmpty,
        );
        if (emptyIdx != -1) {
          listTomorrow[emptyIdx] = item;
        } else {
          listTomorrow.add(item);
        }
      }

      tx.set(
          todayRef,
          {
            'planning': {field: listToday},
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      tx.set(
          tomorrowRef,
          {
            'planning': {field: listTomorrow},
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    });
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
    List<String> dedupePreserveEmptySlots(List<String> input) {
      final seen = <String>{};
      var emptyCount = 0;
      for (final raw in input) {
        final t = raw.toString().trim();
        if (t.isEmpty) {
          emptyCount++;
          continue;
        }
        if (!seen.contains(t)) {
          seen.add(t);
        }
      }
      return [...seen, ...List.filled(emptyCount, '')];
    }

    final fromRef = entryRef(uid, from);
    final toRef = entryRef(uid, to);
    final field = isGoal ? 'goals' : 'todos';
    final needle = itemText.trim();
    if (needle.isEmpty) return;

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final fromSnap = await tx.get(fromRef);
      final fromData = fromSnap.data() ?? <String, dynamic>{};
      final planningFrom =
          (fromData['planning'] as Map<String, dynamic>?) ?? {};
      var listFrom = List<String>.from(planningFrom[field] ?? const <String>[]);
      listFrom = dedupePreserveEmptySlots(listFrom);

      // entferne erste Übereinstimmung
      final idx = listFrom.indexWhere((e) => e.toString().trim() == needle);
      if (idx == -1) return; // nichts zu tun
      listFrom.removeAt(idx);

      final toSnap = await tx.get(toRef);
      final toData = toSnap.data() ?? <String, dynamic>{};
      final planningTo = (toData['planning'] as Map<String, dynamic>?) ?? {};
      var listTo = List<String>.from(planningTo[field] ?? const <String>[]);
      listTo = dedupePreserveEmptySlots(listTo);

      final alreadyThere = listTo.any((e) => e.toString().trim() == needle);
      if (!alreadyThere) {
        final emptyIdx = listTo.indexWhere((e) => e.toString().trim().isEmpty);
        if (emptyIdx != -1) {
          listTo[emptyIdx] = needle;
        } else {
          listTo.add(needle);
        }
      }

      tx.set(
          fromRef,
          {
            'planning': {field: listFrom},
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
      tx.set(
          toRef,
          {
            'planning': {field: listTo},
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    });
  }

  /// Einmalige Datenbereinigung: entfernt Duplikate (trim-basierend)
  /// in planning.goals / planning.todos in allen Tagebucheinträgen
  /// eines Nutzers. Leere Slots bleiben erhalten, werden aber ans
  /// Ende verschoben.
  Future<int> dedupeAllPlanningForUser(String uid) async {
    int updatedDocs = 0;
    var batch = FirebaseFirestore.instance.batch();
    var ops = 0;
    List<String> dedupePreserveEmptySlots(List<String> input) {
      final seen = <String>{};
      var emptyCount = 0;
      for (final raw in input) {
        final t = raw.toString().trim();
        if (t.isEmpty) {
          emptyCount++;
          continue;
        }
        if (!seen.contains(t)) {
          seen.add(t);
        }
      }
      return [...seen, ...List.filled(emptyCount, '')];
    }

    final entries = await _users.doc(uid).collection('entries').get();
    for (final doc in entries.docs) {
      final data = doc.data();
      final planning = (data['planning'] as Map<String, dynamic>?) ?? {};
      final goals = List<String>.from(planning['goals'] ?? const <String>[]);
      final todos = List<String>.from(planning['todos'] ?? const <String>[]);
      final newGoals = dedupePreserveEmptySlots(goals);
      final newTodos = dedupePreserveEmptySlots(todos);
      final changed = newGoals.length != goals.length ||
          newTodos.length != todos.length ||
          !_listsEqual(newGoals, goals) ||
          !_listsEqual(newTodos, todos);
      if (changed) {
        batch.set(
            doc.reference,
            {
              'planning': {'goals': newGoals, 'todos': newTodos},
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
        ops++;
        if (ops >= 450) {
          await batch.commit();
          batch = FirebaseFirestore.instance.batch();
          ops = 0;
        }
        updatedDocs++;
      }
    }
    if (ops > 0) {
      await batch.commit();
    }
    return updatedDocs;
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
