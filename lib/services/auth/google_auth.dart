import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _initialized = false;

  Future<void> _initialize() async {
    if (!_initialized) {
      await _googleSignIn.initialize();
      _initialized = true;
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      await _initialize();

      // Try lightweight / silent authentication first (if user previously signed in)
      GoogleSignInAccount? googleUser = await _googleSignIn.attemptLightweightAuthentication();

      // If that fails or returns null, ask the user to authenticate
      if (googleUser == null) {
        googleUser = await _googleSignIn.authenticate();
        if (googleUser == null) {
          return "Google sign-in cancelled.";
        }
      }

      // Get authentication tokens
      final googleAuth = await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        return "Google ID token is null.";
      }

      // Now you have idToken. If you need accessToken (for scopes beyond basic), you need to do authorization steps

      // Create Firebase credential with idToken
      final credential = GoogleAuthProvider.credential(idToken: idToken);

      // Sign in with Firebase
      await _auth.signInWithCredential(credential);

      return null; // success
    } catch (e) {
      return "Google sign-in failed: $e";
    }
  }

  Future<void> signOut() async {
    await _initialize();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
