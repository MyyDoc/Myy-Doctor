import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myydoctor/data/user/reels_model.dart';

class ReelRepository {

  Stream<List<ReelItems>> getCurrentUserReels() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseDatabase.instance.ref("userReels/$uid");

    return ref.onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null || data is! Map) return [];

      final reelsMap = Map<dynamic, dynamic>.from(data);
      List<ReelItems> reels = [];

      for (var entry in reelsMap.entries) {
        if (entry.value is! Map) continue;

        final reelMap = Map<String, dynamic>.from(entry.value);

        // SAFETY: inject reelId from key if missing
        reelMap['reelId'] ??= entry.key;

        reels.add(ReelItems.fromMap(reelMap));
      }

      // newest first
      reels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reels;
    });
  }
}
