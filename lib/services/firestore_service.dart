import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import '../models/journal_entry.dart';
import '../models/user_model.dart';

class FirestoreService {
  DocumentReference<Map<String, dynamic>> _entryRef(String userId, DateTime date) {
    final id = _dateId(date);
    return FirebaseFirestore.instance.doc('users/$userId/entries/$id');
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _dateId(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
  static int _isoWeekNumber(DateTime date) {
    final thursday = date.add(Duration(days: 3 - ((date.weekday + 6) % 7)));
    final firstThursday = DateTime(thursday.year, 1, 4);
    return 1 + ((thursday.difference(firstThursday).inDays) / 7).floor();
  }
  static DateTime _mondayOfWeek(DateTime d) {
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: (d.weekday + 6) % 7));
  }

  // Public helpers
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
    final end = DateTime(endBase.year, endBase.month, endBase.day, 23, 59, 59, 999);
    return DateTimeRange(start: start, end: end);
  }

  Stream<JournalEntry?> getDailyEntry(String userId, DateTime date) {
    return _entryRef(userId, date).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data()!;
      return JournalEntry.fromMap(snap.id, data);
    });
  }

  Future<void> updateField(String userId, DateTime date, String field, dynamic value) async {
    final ref = _entryRef(userId, date);
    await ref.set({
      field: value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> createEmptyEntry(String userId, DateTime date) async {
    final ref = _entryRef(userId, date);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'planning': null,
        'morning': null,
        'evening': null,
        'ratingFocus': null,
        'ratingEnergy': null,
        'ratingHappiness': null,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> addJournalEntry(JournalEntry entry) async {
    throw UnimplementedError('Method not used in autosave flow');
  }

  Future<List<JournalEntry>> fetchWeekEntries(String uid, DateTime anyDayInWeek) async {
    final range = weekRangeFrom(anyDayInWeek);
    final startId = _dateId(range.start);
    final endId = _dateId(range.start.add(const Duration(days: 6)));
    final col = FirebaseFirestore.instance.collection('users/$uid/entries');
    final snap = await col
        .orderBy(FieldPath.documentId)
        .startAt([startId])
        .endAt([endId])
        .get();
    return snap.docs
        .map((d) => JournalEntry.fromMap(d.id, d.data()))
        .toList();
  }

  Future<void> saveWeeklyReflection(String uid, String weekId, Map<String, dynamic> data) async {
    final ref = FirebaseFirestore.instance.doc('users/$uid/weekly_reflections/$weekId');
    await ref.set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> weeklyReflectionStream(String uid, String weekId) {
    final ref = FirebaseFirestore.instance.doc('users/$uid/weekly_reflections/$weekId');
    return ref.snapshots().map((s) => s.data());
  }

  Future<void> saveUserData(AppUser user) async {
    final users = FirebaseFirestore.instance.collection('users');
    final ref = users.doc(user.uid);
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
  }

  Future<AppUser?> getUser(String uid) async {
    final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    return AppUser.fromMap(data);
  }
}
