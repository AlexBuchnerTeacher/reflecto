import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meal_log.dart';

class MealService {
  final FirebaseFirestore _firestore;
  MealService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<MealLog> _mealsCollection(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('meals')
        .withConverter<MealLog>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data();
            if (data == null)
              throw StateError('MealLog is null for ${snapshot.id}');
            return MealLog.fromMap(snapshot.id, data);
          },
          toFirestore: (log, _) => log.toMap(),
        );
  }

  Stream<MealLog?> watchMealForDate(String uid, DateTime date) {
    final id = dateKey(date);
    return _mealsCollection(uid).doc(id).snapshots().map((doc) => doc.data());
  }

  Future<void> setMealToggle({
    required String uid,
    required DateTime date,
    required String field, // 'breakfast' | 'lunch' | 'dinner'
    required bool value,
  }) async {
    final id = dateKey(date);
    final typedRef = _mealsCollection(uid).doc(id);
    final doc = await typedRef.get();
    final rawRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('meals')
        .doc(id);
    if (!doc.exists) {
      final now = DateTime.now();
      final base = MealLog(
        id: id,
        breakfast: false,
        lunch: false,
        dinner: false,
        breakfastNote: null,
        lunchNote: null,
        dinnerNote: null,
        createdAt: now,
        updatedAt: now,
      );
      await rawRef.set(base.toMap());
    }

    await rawRef.set({
      field: value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setMealNote({
    required String uid,
    required DateTime date,
    required String field, // 'breakfastNote' | 'lunchNote' | 'dinnerNote'
    required String value,
  }) async {
    final id = dateKey(date);
    final typedRef = _mealsCollection(uid).doc(id);
    final doc = await typedRef.get();
    final rawRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('meals')
        .doc(id);
    if (!doc.exists) {
      final now = DateTime.now();
      final base = MealLog(
        id: id,
        breakfast: false,
        lunch: false,
        dinner: false,
        breakfastNote: null,
        lunchNote: null,
        dinnerNote: null,
        createdAt: now,
        updatedAt: now,
      );
      await rawRef.set(base.toMap());
    }
    await rawRef.set({
      field: value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
