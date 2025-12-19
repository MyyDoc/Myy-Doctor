import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myydoctor/data/posts/pic_post_model.dart';

class PicPostRepository {

  Stream<List<PicPostModel>> getPostsStream({required bool useOwnerProfile}) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = useOwnerProfile
        ? FirebaseDatabase.instance.ref("posts")
        : FirebaseDatabase.instance.ref("posts/$uid");

    return ref.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return [];

      List<PicPostModel> posts = [];

      if (useOwnerProfile) {
        final usersMap = Map<dynamic, dynamic>.from(data);

        for (var userEntry in usersMap.entries) {
          if (userEntry.value is! Map) continue;
          final userPosts = Map<dynamic, dynamic>.from(userEntry.value);

          for (var postEntry in userPosts.entries) {
            if (postEntry.value is! Map) continue;

            posts.add(
              PicPostModel.fromMap(
                Map<String, dynamic>.from(postEntry.value),
                id: postEntry.key,
              ),
            );
          }
        }
      } else {
        final postsMap = Map<dynamic, dynamic>.from(data);

        for (var entry in postsMap.entries) {
          if (entry.value is! Map) continue;

          posts.add(
            PicPostModel.fromMap(
              Map<String, dynamic>.from(entry.value),
              id: entry.key,
            ),
          );
        }
      }

      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }
}




