import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
//import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' show Platform;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==================== EMAIL/PASSWORD SIGN UP ====================
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    try {
      // Check if username already exists
      final usernameExists = await _checkUsernameExists(username);
      if (usernameExists) {
        return {
          'success': false,
          'message': 'Username already taken',
        };
      }

      // Create Firebase Auth user
      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Create user document with empty/default values
        await _createUserDocument(
          userId: user.uid,
          email: email,
          username: username,
          fullName: fullName,
          authProvider: 'email',
        );

        // Send email verification
        await user.sendEmailVerification();

        return {
          'success': true,
          'message': 'Account created successfully',
          'user': user,
        };
      }

      return {
        'success': false,
        'message': 'Failed to create account',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // ==================== EMAIL/PASSWORD LOGIN ====================
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Update last login
        await _updateLastLogin(user.uid);

        return {
          'success': true,
          'message': 'Login successful',
          'user': user,
        };
      }

      return {
        'success': false,
        'message': 'Login failed',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // ==================== GOOGLE SIGN IN ====================
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Google sign in cancelled',
        };
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        // Check if this is a new user
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

        if (isNewUser) {
          // Generate username from email
          final username = await _generateUniqueUsername(user.email ?? '');

          // Create user document
          await _createUserDocument(
            userId: user.uid,
            email: user.email ?? '',
            username: username,
            fullName: user.displayName ?? '',
            profilePicture: user.photoURL,
            authProvider: 'google',
            emailVerified: true,
          );
        } else {
          // Update last login
          await _updateLastLogin(user.uid);
        }

        return {
          'success': true,
          'message': 'Google sign in successful',
          'user': user,
          'isNewUser': isNewUser,
        };
      }

      return {
        'success': false,
        'message': 'Google sign in failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Google sign in error: ${e.toString()}',
      };
    }
  }

  // ==================== FACEBOOK SIGN IN ====================
  Future<Map<String, dynamic>> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (loginResult.status == LoginStatus.success) {
        // Get the access token
        final AccessToken? accessToken = loginResult.accessToken;

        if (accessToken == null) {
          return {
            'success': false,
            'message': 'Failed to get access token',
          };
        }

        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(accessToken.tokenString);

        // Sign in to Firebase with the Facebook credential
        final UserCredential userCredential =
        await _auth.signInWithCredential(facebookAuthCredential);

        final User? user = userCredential.user;

        if (user != null) {
          // Check if this is a new user
          final isNewUser =
              userCredential.additionalUserInfo?.isNewUser ?? false;

          if (isNewUser) {
            // Get Facebook user data
            final userData = await FacebookAuth.instance.getUserData();

            // Generate username from email or name
            final username = await _generateUniqueUsername(
              userData['email'] ?? userData['name'] ?? '',
            );

            // Create user document
            await _createUserDocument(
              userId: user.uid,
              email: userData['email'] ?? '',
              username: username,
              fullName: userData['name'] ?? '',
              profilePicture: userData['picture']?['data']?['url'],
              authProvider: 'facebook',
              emailVerified: true,
            );
          } else {
            // Update last login
            await _updateLastLogin(user.uid);
          }

          return {
            'success': true,
            'message': 'Facebook sign in successful',
            'user': user,
            'isNewUser': isNewUser,
          };
        }
      } else if (loginResult.status == LoginStatus.cancelled) {
        return {
          'success': false,
          'message': 'Facebook sign in cancelled',
        };
      }

      return {
        'success': false,
        'message': 'Facebook sign in failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Facebook sign in error: ${e.toString()}',
      };
    }
  }

  /*==================== APPLE SIGN IN ====================
  Future<Map<String, dynamic>> signInWithApple() async {
    try {
      / Check if Apple Sign In is available
      if (!await SignInWithApple.isAvailable()) {
        return {
          'success': false,
          'message': 'Apple Sign In is not available on this device',
        };
      }

      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuth credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final UserCredential userCredential =
      await _auth.signInWithCredential(oauthCredential);

      final User? user = userCredential.user;

      if (user != null) {
        // Check if this is a new user
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

        if (isNewUser) {
          // Get name from Apple credential
          String fullName = '';
          if (appleCredential.givenName != null ||
              appleCredential.familyName != null) {
            fullName =
                '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                    .trim();
          }

          // Generate username
          final username = await _generateUniqueUsername(
            appleCredential.email ?? user.email ?? '',
          );

          // Create user document
          await _createUserDocument(
            userId: user.uid,
            email: appleCredential.email ?? user.email ?? '',
            username: username,
            fullName: fullName.isNotEmpty ? fullName : 'Apple User',
            authProvider: 'apple',
            emailVerified: true,
          );
        } else {
          // Update last login
          await _updateLastLogin(user.uid);
        }

        return {
          'success': true,
          'message': 'Apple sign in successful',
          'user': user,
          'isNewUser': isNewUser,
        };
      }

      return {
        'success': false,
        'message': 'Apple sign in failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Apple sign in error: ${e.toString()}',
      };
    }
  }*/

  // ==================== SIGN OUT ====================
  Future<Map<String, dynamic>> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Facebook
      await FacebookAuth.instance.logOut();

      // Sign out from Firebase
      await _auth.signOut();

      return {
        'success': true,
        'message': 'Sign out successful',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Sign out error: ${e.toString()}',
      };
    }
  }

  // ==================== PASSWORD RESET ====================
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // ==================== DELETE ACCOUNT ====================
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user signed in',
        };
      }

      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth user
      await user.delete();

      return {
        'success': true,
        'message': 'Account deleted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Delete account error: ${e.toString()}',
      };
    }
  }

  // ==================== HELPER METHODS ====================

  // Create user document in Firestore
  Future<void> _createUserDocument({
    required String userId,
    required String email,
    required String username,
    required String fullName,
    String? profilePicture,
    String? phoneNumber,
    required String authProvider,
    bool emailVerified = false,
  }) async {
    final userData = {
      'id': userId,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'profilePicture': profilePicture,
      'bio': null,
      'gender': null,
      'dob': null,
      'lastLogin': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'isVerified': false,
      'emailVerified': emailVerified,
      'phoneVerified': false,
      'savedPosts': [],
      'searchHistory': [],
      'languagePreference': 'en',
      'deviceTokens': [],
      'location': null,
      'badges': [],
      'subscriptionStatus': 'free',
      'walletBalance': 0.0,
      'notificationsEnabled': true,
      'followersList': [],
      'followingList': [],
      'subscribers': [],
      'chatUsers': [],
      'lastSeen': DateTime.now().toIso8601String(),
      'features': [],
      'privacy': 'public',
      'themePreference': 'light',
      'blockedUsers': [],
      'mutedUsers': [],
      'authProvider': authProvider,
    };

    await _firestore.collection('users').doc(userId).set(userData);
  }

  // Update last login
  Future<void> _updateLastLogin(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'lastLogin': DateTime.now().toIso8601String(),
      'lastSeen': DateTime.now().toIso8601String(),
    });
  }

  // Check if username exists
  Future<bool> _checkUsernameExists(String username) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  // Generate unique username
  Future<String> _generateUniqueUsername(String baseString) async {
    // Remove special characters and spaces
    String username = baseString
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .replaceAll('@', '')
        .split('.')[0];

    // Limit to 20 characters
    if (username.length > 20) {
      username = username.substring(0, 20);
    }

    // If username is empty, use a default
    if (username.isEmpty) {
      username = 'user';
    }

    // Check if username exists
    bool exists = await _checkUsernameExists(username);

    if (!exists) {
      return username;
    }

    // If exists, append numbers until we find a unique one
    int counter = 1;
    String newUsername = username;

    while (exists) {
      newUsername = '$username$counter';
      exists = await _checkUsernameExists(newUsername);
      counter++;

      // Safety check to prevent infinite loop
      if (counter > 9999) {
        newUsername = '$username${DateTime.now().millisecondsSinceEpoch}';
        break;
      }
    }

    return newUsername;
  }

  // Get user-friendly error messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid credentials';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'An error occurred. Please try again';
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    await currentUser?.reload();
    return currentUser?.emailVerified ?? false;
  }

  // Resend email verification
  Future<Map<String, dynamic>> resendVerificationEmail() async {
    try {
      await currentUser?.sendEmailVerification();
      return {
        'success': true,
        'message': 'Verification email sent',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send verification email',
      };
    }
  }
}