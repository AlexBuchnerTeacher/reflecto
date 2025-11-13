import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry.dart';
import 'pending_providers.dart';
import '../services/firestore_service.dart';

final _svcProvider = Provider<FirestoreService>((ref) => FirestoreService());

final todayEntryProvider = StreamProvider<JournalEntry?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();
  final svc = ref.read(_svcProvider);
  final today = DateTime.now();
  return svc.getDailyEntry(user.uid, today);
});

final weekEntriesProvider = FutureProvider.family<List<JournalEntry>, DateTime>(
  (ref, anyDayInWeek) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return <JournalEntry>[];
    final svc = ref.read(_svcProvider);
    return svc.fetchWeekEntries(user.uid, anyDayInWeek);
  },
);

// Document stream for today to access snapshot metadata (pending/offline)
final todayDocProvider = StreamProvider<DocumentSnapshot<Map<String, dynamic>>>(
  (ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final id = '${now.year}-${two(now.month)}-${two(now.day)}';
    final doc = FirebaseFirestore.instance.doc('users/${user.uid}/entries/$id');
    return doc.snapshots();
  },
);

// Weekly reflection stream provider
final weeklyReflectionProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, weekId) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return const Stream.empty();
      final refDoc = FirebaseFirestore.instance.doc(
        'users/${user.uid}/weekly_reflections/$weekId',
      );
      return refDoc.snapshots().map((s) => s.data());
    });

// Family providers by date for day views
final dayEntryProvider = StreamProvider.family<JournalEntry?, DateTime>((
  ref,
  date,
) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();
  final svc = ref.read(_svcProvider);
  return svc.getDailyEntry(user.uid, date);
});

final dayDocProvider =
    StreamProvider.family<DocumentSnapshot<Map<String, dynamic>>, DateTime>((
      ref,
      date,
    ) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return const Stream.empty();
      String two(int n) => n.toString().padLeft(2, '0');
      final id = '${date.year}-${two(date.month)}-${two(date.day)}';
      final doc = FirebaseFirestore.instance.doc(
        'users/${user.uid}/entries/$id',
      );
      return doc.snapshots();
    });

// Update helpers exposed via providers
typedef UpdateDayField =
    Future<void> Function(
      String uid,
      DateTime date,
      String field,
      dynamic value,
    );

final updateDayFieldProvider = Provider<UpdateDayField>((ref) {
  final svc = ref.read(_svcProvider);
  final pending = ref.read(pendingWritesProvider.notifier);
  return (String uid, DateTime date, String field, dynamic value) async {
    pending.state++;
    try {
      await svc.updateField(uid, date, field, value);
    } finally {
      pending.state--;
    }
  };
});
