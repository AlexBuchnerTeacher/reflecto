import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/user_model.dart';

/// Service für User-CRUD in Firestore.
class FirestoreUserService {
  FirestoreUserService._();
  static final FirestoreUserService instance = FirestoreUserService._();
  factory FirestoreUserService() => instance;

  final CollectionReference<Map<String, dynamic>> _users = FirebaseFirestore
      .instance
      .collection('users');

  Future<void> saveUserData(AppUser user) async {
    try {
      final ref = _users.doc(user.uid);
      final snap = await ref.get();
      if (!snap.exists) {
        // Create: write only known non-null fields + server timestamps.
        final create = <String, dynamic>{
          'uid': user.uid,
          if (user.displayName != null) 'displayName': user.displayName,
          if (user.email != null) 'email': user.email,
          if (user.photoUrl != null) 'photoUrl': user.photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        };
        await ref.set(create, SetOptions(merge: true));
      } else {
        // Update: avoid overwriting createdAt; write only provided non-null fields.
        final update = <String, dynamic>{
          if (user.displayName != null) 'displayName': user.displayName,
          if (user.email != null) 'email': user.email,
          if (user.photoUrl != null) 'photoUrl': user.photoUrl,
          'lastLoginAt': FieldValue.serverTimestamp(),
        };
        if (update.isNotEmpty) {
          await ref.set(update, SetOptions(merge: true));
        } else {
          // Still refresh lastLoginAt if nothing else changes
          await ref.set({
            'lastLoginAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
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
}
