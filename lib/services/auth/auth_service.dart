import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create user, send verification email and save user info to Firestore.
  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) return "User creation failed.";

      // send verification email
      await user.sendEmailVerification();

      // Save user meta in Firestore under collection "users"
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email.trim(),
        'fullName': fullName.trim(),
        'username': username.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': false,
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Sign in by email + password, only if email is verified.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) return "User not found.";

      if (!user.emailVerified) {
        // Optionally you can re-send verification email here if needed:
        // await user.sendEmailVerification();
        await _auth.signOut(); // sign out the unverified user
        return "Please verify your email before logging in.";
      }

      // Update Firestore verification flag (in case user verified elsewhere)
      await _firestore.collection('users').doc(user.uid).update({
        'isVerified': true,
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Given a username find the user's email (used for username-based login)
  Future<String?> getEmailFromUsername(String username) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first.data()['email'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
