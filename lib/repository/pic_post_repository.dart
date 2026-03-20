import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myydoctor/data/posts/pic_post_model.dart';

class PicPostRepository {
  static final Map<String, bool> _doctorCache = {};

  Stream<List<PicPostModel>> getPostsStream({
    required bool useOwnerProfile,
    required String anotherProfile,
  }) {
    final controller = StreamController<List<PicPostModel>>();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      controller.add([]);
      return controller.stream;
    }

    final uid = currentUser.uid;
    final targetUid =
    useOwnerProfile ? null : (anotherProfile.isNotEmpty ? anotherProfile : uid);

    final postsRef = useOwnerProfile
        ? FirebaseDatabase.instance.ref("posts")
        : FirebaseDatabase.instance.ref("posts/$targetUid");

    final savedRef = FirebaseDatabase.instance.ref("savedPosts/$uid");
    final blockedRef =
    FirebaseDatabase.instance.ref("users/$uid/blockedUsers");

    Set<String> savedPostIds = {};
    Set<String> blockedUsers = {};

    Future<void> fetchAndEmit() async {
      final event = await postsRef.get();
      final data = event.value;

      if (data == null || data is! Map) {
        controller.add([]);
        return;
      }

      final List<PicPostModel> posts = [];

      if (useOwnerProfile) {
        final usersMap = data as Map<dynamic, dynamic>;

        for (final userEntry in usersMap.entries) {
          final ownerId = userEntry.key as String;

          // 🚫 Skip blocked users
          if (blockedUsers.contains(ownerId)) continue;

          if (userEntry.value is! Map) continue;

          final bool isDoctor = await _getIsDoctor(ownerId);
          final userPostsMap = userEntry.value as Map<dynamic, dynamic>;

          for (final postEntry in userPostsMap.entries) {
            final String postId = postEntry.key as String;
            if (postEntry.value is! Map) continue;

            final postMap = postEntry.value as Map<dynamic, dynamic>;

            String? name;
            String? profileImageUrl;

            final userSnap =
            await FirebaseDatabase.instance.ref('users/$ownerId').get();

            if (userSnap.exists && userSnap.value is Map) {
              final userData = userSnap.value as Map<dynamic, dynamic>;
              name = userData['username'] as String?;
              profileImageUrl = userData['profileImageUrl'] as String?;
            }

            posts.add(PicPostModel(
              postId: postId,
              ownerId: ownerId,
              caption: postMap['caption']?.toString() ?? '',
              imageUrl: postMap['imageUrl']?.toString() ?? '',
              likeCount: (postMap['likeCount'] as num?)?.toInt() ?? 0,
              commentCount:
              (postMap['commentCount'] as num?)?.toInt() ?? 0,
              name: name ?? postMap['username']?.toString(),
              profileImageUrl:
              profileImageUrl ?? postMap['profileImageUrl']?.toString(),
              createdAt: (postMap['createdAt'] as num?)?.toInt() ?? 0,
              isSaved: savedPostIds.contains(postId),
              isOwnerDoctor: isDoctor,
            ));
          }
        }
      } else {
        if (blockedUsers.contains(targetUid)) {
          controller.add([]);
          return;
        }

        final bool isOwnerDoctor = await _getIsDoctor(targetUid!);

        final postsMap = data as Map<dynamic, dynamic>;

        for (final postEntry in postsMap.entries) {
          final String postId = postEntry.key as String;
          if (postEntry.value is! Map) continue;

          final postMap = postEntry.value as Map<dynamic, dynamic>;

          posts.add(PicPostModel(
            postId: postId,
            ownerId: targetUid,
            caption: postMap['caption']?.toString() ?? '',
            imageUrl: postMap['imageUrl']?.toString() ?? '',
            likeCount: (postMap['likeCount'] as num?)?.toInt() ?? 0,
            commentCount:
            (postMap['commentCount'] as num?)?.toInt() ?? 0,
            name: postMap['username']?.toString(),
            profileImageUrl: postMap['profileImageUrl']?.toString(),
            createdAt: (postMap['createdAt'] as num?)?.toInt() ?? 0,
            isSaved: savedPostIds.contains(postId),
            isOwnerDoctor: isOwnerDoctor,
          ));
        }
      }

      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller.add(posts);
    }

    // 🔥 Listen to changes
    savedRef.onValue.listen((event) {
      final data = event.snapshot.value;
      savedPostIds = {};

      if (data != null && data is Map) {
        savedPostIds.addAll(data.keys.cast<String>());
      }

      fetchAndEmit();
    });

    blockedRef.onValue.listen((event) {
      final data = event.snapshot.value;
      blockedUsers = {};

      if (data != null && data is Map) {
        blockedUsers.addAll(data.keys.cast<String>());
      }

      fetchAndEmit();
    });

    postsRef.onValue.listen((_) {
      fetchAndEmit();
    });

    return controller.stream;
  }

  Stream<List<PicPostModel>> getSavedPostsStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('getSavedPostsStream: No current user');
      return Stream.value(<PicPostModel>[]);
    }

    final uid = currentUser.uid;
    print('getSavedPostsStream: Fetching for user $uid');

    final savedRef = FirebaseDatabase.instance
        .ref()
        .child('savedPosts')
        .child(uid);

    // User's own posts ref
    final ownPostsRef = FirebaseDatabase.instance.ref('posts/$uid');

    return savedRef.onValue.asyncExpand((savedEvent) {
      // Get saved post IDs and ownerIds
      final Map<String, String> savedPostToOwner = {}; // postId → ownerId
      if (savedEvent.snapshot.exists && savedEvent.snapshot.value != null) {
        final savedData = savedEvent.snapshot.value as Map<dynamic, dynamic>;
        for (final entry in savedData.entries) {
          final postId = entry.key as String?;
          if (postId == null) continue;
          final value = entry.value as Map<dynamic, dynamic>?;
          final ownerId = value?['ownerId'] as String?;
          if (ownerId != null) {
            savedPostToOwner[postId] = ownerId;
          }
        }
      }

      // Now listen to both: saved posts + own posts
      return ownPostsRef.onValue.asyncMap((ownEvent) async {
        final List<Future<PicPostModel?>> futures = [];

        // 1. Process OWN uploaded posts
        if (ownEvent.snapshot.exists && ownEvent.snapshot.value != null) {
          final ownPostsMap = ownEvent.snapshot.value as Map<dynamic, dynamic>;

          for (final entry in ownPostsMap.entries) {
            final postId = entry.key as String?;
            if (postId == null) continue;

            final postMap = entry.value as Map<dynamic, dynamic>?;
            if (postMap == null) continue;

            futures.add(_buildPostModelFromMap(
              postMap,
              postId,
              uid, // owner is current user
              isSaved: savedPostToOwner.containsKey(postId), // mark as saved if it is
            ));
          }
        }

        // 2. Process SAVED posts (from other users or own)
        for (final savedEntry in savedPostToOwner.entries) {
          final postId = savedEntry.key;
          final ownerId = savedEntry.value;

          // Skip if it's the user's own post (already added above)
          if (ownerId == uid) continue;

          futures.add(() async {
            try {
              final postRef = FirebaseDatabase.instance
                  .ref('posts/$ownerId/$postId');

              print('Querying saved post at: posts/$ownerId/$postId');

              final postSnap = await postRef.get();

              if (!postSnap.exists || postSnap.value == null) {
                print('Saved post NOT FOUND: $postId');
                return null;
              }

              final postMap = postSnap.value as Map<dynamic, dynamic>;

              return await _buildPostModelFromMap(
                postMap,
                postId,
                ownerId,
                isSaved: true,
              );
            } catch (e) {
              print('Error loading saved post $postId: $e');
              return null;
            }
          }());
        }

        final results = await Future.wait(futures);
        final validPosts = results.whereType<PicPostModel>().toList();

        // Remove duplicates (if somehow added twice)
        final uniquePosts = <String, PicPostModel>{};
        for (final post in validPosts) {
          uniquePosts[post.postId] = post;
        }

        final finalList = uniquePosts.values.toList();

        // Sort newest first
        finalList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        print('Final saved + own posts count: ${finalList.length}');
        return finalList;
      });
    });
  }

  /// Helper to build PicPostModel from post map
  Future<PicPostModel> _buildPostModelFromMap(
      Map<dynamic, dynamic> postMap,
      String postId,
      String ownerId, {
        required bool isSaved,
      }) async {
    String? name;
    String? profileImageUrl;
    bool isOwnerDoctor = await _getIsDoctor(ownerId);

    final userRef = FirebaseDatabase.instance.ref('users/$ownerId');
    final userSnap = await userRef.get();

    if (userSnap.exists && userSnap.value != null) {
      final userData = userSnap.value as Map<dynamic, dynamic>;
      name = userData['username'] as String?;
      profileImageUrl = userData['profileImageUrl'] as String?;
    }

    var model = PicPostModel.fromMap(
      postMap.cast<String, dynamic>(),
      postId,
      ownerId,
      isSaved: isSaved,
      isOwnerDoctor: isOwnerDoctor,
    );

    if (name != null) model = model.copyWith(name: name);
    if (profileImageUrl != null) {
      model = model.copyWith(profileImageUrl: profileImageUrl);
    }

    return model;
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

  Future<Set<String>> _getBlockedUsers(String uid) async {
    final ref = FirebaseDatabase.instance.ref('users/$uid/blockedUsers');
    final snapshot = await ref.get();

    final Set<String> blocked = {};

    if (snapshot.exists && snapshot.value != null) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      blocked.addAll(data.keys.cast<String>());
    }

    return blocked;
  }
}