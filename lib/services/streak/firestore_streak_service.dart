import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../entry/firestore_entry_service.dart';

/// Service für Streak-Management (Abendabschluss -> Streak aktualisieren).
class FirestoreStreakService {
  FirestoreStreakService._();
  static final FirestoreStreakService instance = FirestoreStreakService._();
  factory FirestoreStreakService() => instance;

  final CollectionReference<Map<String, dynamic>> _users = FirebaseFirestore
      .instance
      .collection('users');

  Future<void> markEveningCompletedAndUpdateStreak(
    String uid,
    DateTime date,
  ) async {
    try {
      // Abend als completed markieren
      await FirestoreEntryService.instance.updateField(
        uid,
        date,
        'evening.completed',
        true,
      );

      final todayId = FirestoreEntryService.instance.formatDate(date);
      final yesterday = date.subtract(const Duration(days: 1));
      final yId = FirestoreEntryService.instance.formatDate(yesterday);

      final ySnap = await FirestoreEntryService.instance
          .entryRef(uid, yesterday)
          .get();
      final yCompleted = (ySnap.data()?['evening']?['completed'] == true);

      final streakRef = _users.doc(uid).collection('stats').doc('streak');
      final snap = await streakRef.get();
      final data = snap.data() ?? <String, dynamic>{};
      final lastDate = data['lastEntryDate'] as String?;
      final current = (data['streakCount'] is num)
          ? (data['streakCount'] as num).toInt()
          : 0;
      final longest = (data['longestStreak'] is num)
          ? (data['longestStreak'] as num).toInt()
          : 0;

      if (lastDate == todayId) {
        return; // heute bereits gezählt
      }

      final shouldChain = yCompleted && (lastDate == yId || lastDate == null);
      final next = shouldChain ? (current + 1) : 1;
      final nextLongest = next > longest ? next : longest;
      await streakRef.set({
        'streakCount': next,
        'longestStreak': nextLongest,
        'lastEntryDate': todayId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      debugPrint('Firestore error (markEveningCompletedAndUpdateStreak): $e');
      rethrow;
    }
  }
}
