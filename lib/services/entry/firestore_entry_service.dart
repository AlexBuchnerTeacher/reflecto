import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/journal_entry.dart';

/// Kleine, fokussierte Service-Klasse für Eintrags-CRUD-Operationen.
class FirestoreEntryService {
  FirestoreEntryService._();
  static final FirestoreEntryService instance = FirestoreEntryService._();
  factory FirestoreEntryService() => instance;

  final CollectionReference<Map<String, dynamic>> _users = FirebaseFirestore
      .instance
      .collection('users');

  DocumentReference<Map<String, dynamic>> entryRef(String uid, DateTime date) {
    return _users.doc(uid).collection('entries').doc(_formatDate(date));
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _formatDate(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';

  /// Öffentliche Wrapper für Datumshilfen (für Kompatibilität / Delegation).
  String formatDate(DateTime d) => _formatDate(d);
  String two(int n) => _two(n);

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

  Future<void> createEmptyEntry(String uid, DateTime date) =>
      ensureEntry(uid, date);

  Stream<JournalEntry?> getDailyEntry(String uid, DateTime date) {
    final ref = entryRef(uid, date);
    return ref.snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return JournalEntry.fromMap(snap.id, data);
    });
  }

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
        final nested = _mapFromPath(fieldPath, value);
        nested['updatedAt'] = FieldValue.serverTimestamp();
        await ref.set(nested, SetOptions(merge: true));
      } else {
        debugPrint('Firestore error (updateField): $e');
        rethrow;
      }
    }
  }

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

  Future<List<JournalEntry>> fetchWeekEntries(
    String uid,
    DateTime anyDayInWeek,
  ) async {
    try {
      final monday = anyDayInWeek.subtract(
        Duration(days: (anyDayInWeek.weekday + 6) % 7),
      );
      final startId = _formatDate(
        DateTime(monday.year, monday.month, monday.day),
      );
      final endId = _formatDate(monday.add(const Duration(days: 6)));
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
}
