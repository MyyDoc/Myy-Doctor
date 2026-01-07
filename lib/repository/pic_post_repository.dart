import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myydoctor/data/posts/pic_post_model.dart';

class PicPostRepository {
  /// Streams all posts (global feed) or only user's posts (profile)
  Stream<List<PicPostModel>> getPostsStream({required bool useOwnerProfile}) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    final uid = currentUser.uid;

    // Reference to posts
    final DatabaseReference postsRef = useOwnerProfile
        ? FirebaseDatabase.instance.ref("posts")
        : FirebaseDatabase.instance.ref("posts/$uid");

    // Also listen to current user's saved posts once (efficient!)
    final DatabaseReference savedRef =
    FirebaseDatabase.instance.ref("savedPosts/$uid");

    // Combine both streams using RxDart or manual combine
    return savedRef.onValue.asyncExpand((savedEvent) {
      final Set<String> savedPostIds = {};

      if (savedEvent.snapshot.value != null) {
        final savedData = Map<dynamic, dynamic>.from(savedEvent.snapshot.value as Map);
        savedPostIds.addAll(savedData.keys.map((key) => key.toString()));
      }

      return postsRef.onValue.map((event) {
        final data = event.snapshot.value;
        if (data == null || data is! Map) return <PicPostModel>[];

        final List<PicPostModel> posts = [];

        if (useOwnerProfile) {
          // Global feed: iterate through all users
          final usersMap = Map<dynamic, dynamic>.from(data);

          for (var userEntry in usersMap.entries) {
            final String ownerId = userEntry.key.toString();
            if (userEntry.value is! Map) continue;

            final userPostsMap = Map<dynamic, dynamic>.from(userEntry.value);

            for (var postEntry in userPostsMap.entries) {
              final String postId = postEntry.key.toString();
              if (postEntry.value is! Map) continue;

              final postMap = Map<String, dynamic>.from(postEntry.value as Map);

              posts.add(PicPostModel(
                postId: postId,
                ownerId: ownerId,
                caption: postMap['caption'] ?? '',
                imageUrl: postMap['imageUrl'] ?? '',
                likeCount: postMap['likeCount'] ?? 0,
                commentCount: postMap['commentCount'] ?? 0,
                name: postMap['username'] as String?,
                profileImageUrl: postMap['profileImageUrl'] as String?,
                createdAt: postMap['createdAt'] ?? 0,
                isSaved: savedPostIds.contains(postId),
              ));
            }
          }
        } else {
          // Profile feed: only current user's posts
          final postsMap = Map<dynamic, dynamic>.from(data);

          for (var entry in postsMap.entries) {
            final String postId = entry.key.toString();
            if (entry.value is! Map) continue;

            final postMap = Map<String, dynamic>.from(entry.value as Map);

            posts.add(PicPostModel(
              postId: postId,
              ownerId: uid,
              caption: postMap['caption'] ?? '',
              imageUrl: postMap['imageUrl'] ?? '',
              likeCount: postMap['likeCount'] ?? 0,
              commentCount: postMap['commentCount'] ?? 0,
              name: postMap['username'] as String?,
              profileImageUrl: postMap['profileImageUrl'] as String?,
              createdAt: postMap['createdAt'] ?? 0,
              isSaved: savedPostIds.contains(postId),
            ));
          }
        }

        // Sort by newest first
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return posts;
      });
    });
  }
}