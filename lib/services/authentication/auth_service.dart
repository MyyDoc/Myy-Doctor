import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ---------------- SIGN UP ----------------
  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    try {
      // Create user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Save extra user details in Firestore
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
        "fullName": fullName,
        "username": username.toLowerCase(),
        "createdAt": DateTime.now(),
      });

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// ---------------- LOGIN (Email or Username) ----------------
  Future<String?> signIn({
    required String loginInput,
    required String password,
  }) async {
    try {
      String email = loginInput;

      // If user entered a username — convert username → email
      if (!loginInput.contains("@")) {
        email = await getEmailFromUsername(loginInput);
      }

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// ---------------- USERNAME → EMAIL ----------------
  Future<String> getEmailFromUsername(String username) async {
    final snapshot = await _firestore
        .collection("users")
        .where("username", isEqualTo: username.toLowerCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw FirebaseAuthException(
        code: "user-not-found",
        message: "Username does not exist.",
      );
    }

    return snapshot.docs.first["email"];
  }

  /// ---------------- LOGOUT ----------------
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
