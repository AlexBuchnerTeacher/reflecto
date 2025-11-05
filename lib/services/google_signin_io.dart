import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> signInWithGooglePlatform(FirebaseAuth auth) async {
  throw FirebaseAuthException(
    code: 'google-signin-unsupported',
    message: 'Google Login ist auf dieser Plattform nicht verfügbar',
  );
}

Future<void> tryGoogleSignOutPlatform() async {}
