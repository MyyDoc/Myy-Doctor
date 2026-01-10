import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myydoctor/data/posts/pic_post_model.dart';

class PicPostRepository {
  // Simple in-memory cache: userId → isDoctor
  static final Map<String, bool> _doctorCache = {};

  /// Streams all posts (global feed) or only user's own posts (profile)
  Stream<List<PicPostModel>> getPostsStream({
    required bool useOwnerProfile,
  }) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    final uid = currentUser.uid;

    // Posts reference
    final DatabaseReference postsRef = useOwnerProfile
        ? FirebaseDatabase.instance.ref("posts")
        : FirebaseDatabase.instance.ref("posts/$uid");

    // Current user's saved posts
    final DatabaseReference savedRef =
    FirebaseDatabase.instance.ref("savedPosts/$uid");

    return savedRef.onValue.asyncExpand((savedEvent) {
      // Build set of saved post IDs
      final Set<String> savedPostIds = {};
      if (savedEvent.snapshot.value != null) {
        final savedData = savedEvent.snapshot.value as Map;
        savedPostIds.addAll(savedData.keys.map((key) => key.toString()));
      }

      return postsRef.onValue.asyncMap((event) async {
        final data = event.snapshot.value;
        if (data == null || data is! Map) return <PicPostModel>[];

        final List<PicPostModel> posts = [];

        if (useOwnerProfile) {
          // ── GLOBAL FEED ── multiple users' posts
          final usersMap = data as Map;

          for (final userEntry in usersMap.entries) {
            final String ownerId = userEntry.key as String;
            if (userEntry.value is! Map) continue;

            // Get (and cache) whether this user is a doctor
            final bool isDoctor = await _getIsDoctor(ownerId);

            final userPostsMap = userEntry.value as Map;

            for (final postEntry in userPostsMap.entries) {
              final String postId = postEntry.key as String;
              if (postEntry.value is! Map) continue;

              final postMap = postEntry.value as Map;

              posts.add(PicPostModel(
                postId: postId,
                ownerId: ownerId,
                caption: postMap['caption']?.toString() ?? '',
                imageUrl: postMap['imageUrl']?.toString() ?? '',
                likeCount: (postMap['likeCount'] as num?)?.toInt() ?? 0,
                commentCount: (postMap['commentCount'] as num?)?.toInt() ?? 0,
                name: postMap['username']?.toString(),
                profileImageUrl: postMap['profileImageUrl']?.toString(),
                createdAt: (postMap['createdAt'] as num?)?.toInt() ?? 0,
                isSaved: savedPostIds.contains(postId),
                isOwnerDoctor: isDoctor,
              ));
            }
          }
        } else {
          // ── PROFILE FEED ── only current user's posts
          final bool isCurrentUserDoctor = await _getIsDoctor(uid);

          final postsMap = data as Map;

          for (final postEntry in postsMap.entries) {
            final String postId = postEntry.key as String;
            if (postEntry.value is! Map) continue;

            final postMap = postEntry.value as Map;

            posts.add(PicPostModel(
              postId: postId,
              ownerId: uid,
              caption: postMap['caption']?.toString() ?? '',
              imageUrl: postMap['imageUrl']?.toString() ?? '',
              likeCount: (postMap['likeCount'] as num?)?.toInt() ?? 0,
              commentCount: (postMap['commentCount'] as num?)?.toInt() ?? 0,
              name: postMap['username']?.toString(),
              profileImageUrl: postMap['profileImageUrl']?.toString(),
              createdAt: (postMap['createdAt'] as num?)?.toInt() ?? 0,
              isSaved: savedPostIds.contains(postId),
              isOwnerDoctor: isCurrentUserDoctor,
            ));
          }
        }

        // Sort newest first
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return posts;
      });
    });
  }

  static Future<bool> _getIsDoctor(String uid) async {
    // Return from cache if available
    if (_doctorCache.containsKey(uid)) {
      return _doctorCache[uid]!;
    }

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!docSnapshot.exists) {
        _doctorCache[uid] = false;
        return false;
      }

      final userData = docSnapshot.data();
      if (userData == null) {
        _doctorCache[uid] = false;
        return false;
      }

      final preference = userData['userPreference'] as List<dynamic>?;

      final isDoctor = preference != null &&
          preference.isNotEmpty &&
          (preference[0] as String?)?.toLowerCase() == 'doctor';

      _doctorCache[uid] = isDoctor;
      return isDoctor;
    } catch (e) {
      _doctorCache[uid] = false;
      return false;
    }
  }

  /// Optional: Call this when user logs out or app closes
  static void clearCache() {
    _doctorCache.clear();
  }
}