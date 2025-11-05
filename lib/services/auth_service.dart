import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import 'firestore_service.dart';
import 'google_signin_stub.dart' if (dart.library.io) 'google_signin_io.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _db = FirestoreService();

  Stream<User?> get userChanges => _auth.userChanges();

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      final credential = await _auth.signInWithPopup(provider);
      await _postSignIn(credential.user);
      return credential;
    } else {
      final credential = await signInWithGooglePlatform(_auth);
      await _postSignIn(credential.user);
      return credential;
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _postSignIn(credential.user);
    return credential;
  }

  Future<UserCredential> registerWithEmail(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await _postSignIn(credential.user, isNew: true);
    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await tryGoogleSignOutPlatform();
  }

  Future<void> _postSignIn(User? user, {bool isNew = false}) async {
    if (user == null) return;
    final appUser = AppUser(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
      createdAt: isNew ? DateTime.now() : null,
    );
    await _db.saveUserData(appUser);
  }
}

