import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myydoctor/data/posts/pic_post_model.dart';

class PicPostRepository {
  Stream<List<PicPostModel>> getUserPostsStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userPostsRef =
        FirebaseDatabase.instance.ref().child('posts').child(userId!);

    return userPostsRef.onValue.asyncMap((event) async {
      final data = event.snapshot.value;
      if (data == null) return <PicPostModel>[];

      final Map<dynamic, dynamic> userPosts =
          data as Map<dynamic, dynamic>;

      final List<PicPostModel> posts = [];

      // Loop through all posts
      for (var entry in userPosts.entries) {
        final postData = Map<dynamic, dynamic>.from(entry.value);
        final postModel = PicPostModel.fromMap(postData);

        // Fetch user profile from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(postModel.ownerId)
            .get();

        if (userDoc.exists) {
          final userMap = userDoc.data()!;
          postModel.name = userMap["fullName"];
          postModel.profileImageUrl = userMap["profilePicture"];
        }

        posts.add(postModel);
      }

      // Sort by timestamp
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }
}
