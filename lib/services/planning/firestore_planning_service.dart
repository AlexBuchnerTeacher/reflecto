import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../utils/firestore_date_utils.dart';

/// Fokussiertes Service-Modul für Planung-bezogene Firestore-Operationen.
class FirestorePlanningService {
  FirestorePlanningService._();
  static final FirestorePlanningService instance = FirestorePlanningService._();
  factory FirestorePlanningService() => instance;

  final CollectionReference<Map<String, dynamic>> _users = FirebaseFirestore
      .instance
      .collection('users');

  Future<Map<String, dynamic>?> getPlanningOfPreviousDay(
    String uid,
    DateTime date,
  ) async {
    try {
      final prev = date.subtract(const Duration(days: 1));
      final snap = await _users
          .doc(uid)
          .collection('entries')
          .doc(FirestoreDateUtils.formatDate(prev))
          .get();
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

  // date helpers moved to FirestoreDateUtils

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
      return [...seen, ...List.filled(emptyCount, '')];
    }

    final todayRef = _users
        .doc(uid)
        .collection('entries')
        .doc(FirestoreDateUtils.formatDate(date));
    final tomorrowRef = _users
        .doc(uid)
        .collection('entries')
        .doc(FirestoreDateUtils.formatDate(date.add(const Duration(days: 1))));
    final field = isGoal ? 'goals' : 'todos';
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final todaySnap = await tx.get(todayRef);
      final todayData = todaySnap.data() ?? <String, dynamic>{};
      final planningToday =
          (todayData['planning'] as Map<String, dynamic>?) ?? {};
      var listToday = List<String>.from(
        planningToday[field] ?? const <String>[],
      );
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
      listTomorrow = dedupePreserveEmptySlots(listTomorrow);
      final alreadyThere = listTomorrow.any((e) => e.toString().trim() == item);
      if (!alreadyThere) {
        final emptyIdx = listTomorrow.indexWhere(
          (e) => (e.toString().trim()).isEmpty,
        );
        if (emptyIdx != -1) {
          listTomorrow[emptyIdx] = item;
        } else {
          listTomorrow.add(item);
        }
      }

      tx.set(todayRef, {
        'planning': {field: listToday},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      tx.set(tomorrowRef, {
        'planning': {field: listTomorrow},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

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

    final fromRef = _users
        .doc(uid)
        .collection('entries')
        .doc(FirestoreDateUtils.formatDate(from));
    final toRef = _users
        .doc(uid)
        .collection('entries')
        .doc(FirestoreDateUtils.formatDate(to));
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

      final idx = listFrom.indexWhere((e) => e.toString().trim() == needle);
      if (idx == -1) return;
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

      tx.set(fromRef, {
        'planning': {field: listFrom},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      tx.set(toRef, {
        'planning': {field: listTo},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<int> dedupeAllPlanningForUser(String uid) async {
    int updatedDocs = 0;
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
      final changed =
          newGoals.length != goals.length ||
          newTodos.length != todos.length ||
          !_listsEqual(newGoals, goals) ||
          !_listsEqual(newTodos, todos);
      if (changed) {
        await doc.reference.set({
          'planning': {'goals': newGoals, 'todos': newTodos},
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        updatedDocs++;
      }
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

  /// Public helper for list equality used by other services.
  bool listsEqual(List<String> a, List<String> b) => _listsEqual(a, b);
}
