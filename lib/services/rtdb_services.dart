import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myydoctor/data/user/user_model.dart';


class UserRTDBService {
  final _db = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  /// Create or update user
  Future<void> saveUser(UserModel user) async {
    await _db.child('users').child(user.id).update(user.toJson());
  }

  /// Get user once
  Future<UserModel?> getUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final snapshot = await _db.child('users/$uid').get();
    if (!snapshot.exists) return null;

    return UserModel.fromJson(
      Map<String, dynamic>.from(snapshot.value as Map),
    );
  }

  /// Stream user (real-time updates)
  Stream<UserModel?> userStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _db.child('users/$uid').onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return UserModel.fromJson(
        Map<String, dynamic>.from(event.snapshot.value as Map),
      );
    });
  }
}
