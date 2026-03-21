import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class UserRepoImplementation {

  Future<bool> blockUser(String currentUid, String targetUserId) async {
    try {
      final db = FirebaseDatabase.instance.ref();

      final blockedRef =
      db.child('users/$currentUid/blockedUsers/$targetUserId');
      final followingRef =
      db.child('users/$currentUid/followingList/$targetUserId');
      final followersRef =
      db.child('users/$targetUserId/followersList/$currentUid');

      await blockedRef.set(true);

      await followingRef.remove();
      await followersRef.remove();

      debugPrint("User blocked successfully");

      return true;
    } catch (e) {
      debugPrint("Block user error: $e");
      return false;
    }
  }

  Future<bool> reportUser({
    required String currentUid,
    required String targetUserId,
    required String reason,
  }) async {

    try {
      final reportRef = FirebaseDatabase.instance.ref('reports').push();

      await reportRef.set({
        "reportedUserId": targetUserId,
        "reportedBy": currentUid,
        "reason": reason,
        "timestamp": ServerValue.timestamp,
      });

      debugPrint("User reported successfully");

      return true;
    } catch (e) {
      return false;
    }

  }
}