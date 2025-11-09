import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StreakInfo {
  final int current;
  final int longest;
  final String? lastDate;
  const StreakInfo({
    required this.current,
    required this.longest,
    this.lastDate,
  });
}

final streakDocProvider =
    StreamProvider<DocumentSnapshot<Map<String, dynamic>>?>((ref) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return const Stream.empty();
      final doc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('streak');
      return doc.snapshots();
    });

final streakInfoProvider = Provider<StreakInfo?>((ref) {
  final snap = ref.watch(streakDocProvider).valueOrNull;
  final data = snap?.data();
  if (data == null) return null;
  final current = (data['streakCount'] is num)
      ? (data['streakCount'] as num).toInt()
      : 0;
  final longest = (data['longestStreak'] is num)
      ? (data['longestStreak'] as num).toInt()
      : current;
  final lastDate = data['lastEntryDate'] as String?;
  return StreakInfo(current: current, longest: longest, lastDate: lastDate);
});
