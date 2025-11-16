import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service für Weekly-Reflection Speicherung / Stream.
class FirestoreWeeklyService {
  FirestoreWeeklyService._();
  static final FirestoreWeeklyService instance = FirestoreWeeklyService._();
  factory FirestoreWeeklyService() => instance;

  final CollectionReference<Map<String, dynamic>> _users = FirebaseFirestore
      .instance
      .collection('users');

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
}
