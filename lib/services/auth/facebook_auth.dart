import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> signInWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        return "Facebook sign-in cancelled or failed.";
      }
      final credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);

      await _auth.signInWithCredential(credential);
      return null;
    } catch (e) {
      return "Facebook sign-in failed: $e";
    }
  }

  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }
}
