import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:myydoctor/data/posts/pic_post_model.dart';

class PicPostRepository {
  /// If [useOwnerProfile] = true:
  ///   Firestore lookup uses postModel.ownerId  (global-style profile)
  ///
  /// If [useOwnerProfile] = false:
  ///   Firestore lookup always uses current userId (current-user profile)
  Stream<List<PicPostModel>> getPostsStream({
    required bool useOwnerProfile,
  }) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value(<PicPostModel>[]);

    final userPostsRef =
        FirebaseDatabase.instance.ref().child('posts').child(userId);

    return userPostsRef.onValue
        .asyncMap((event) async {
          try {
            final data = event.snapshot.value;
            if (data == null) return <PicPostModel>[];

            if (data is! Map) {
              print('getPostsStream: Data is not a Map → $data');
              debugPrint("❌ getPostsStream: Data is not a Map → $data");
              return <PicPostModel>[];
            }

            final Map<dynamic, dynamic> userPosts =
                Map<dynamic, dynamic>.from(data);

            final List<PicPostModel> posts = [];

            for (var entry in userPosts.entries) {
              try {
                final postData = Map<dynamic, dynamic>.from(entry.value);
                final postModel = PicPostModel.fromMap(postData);

                // Decide which profile ID to use
                final profileId =
                    useOwnerProfile ? postModel.ownerId : userId;

                final userDoc = await FirebaseFirestore.instance
                    .collection("users")
                    .doc(profileId)
                    .get();

                if (userDoc.exists) {
                  final userMap = userDoc.data()!;
                  postModel.name = userMap["fullName"];
                  postModel.profileImageUrl = userMap["profilePicture"];
                } else {
                  print(
                    "⚠️ No Firestore user found for profileId: $profileId",
                  );
                  debugPrint(
                    "⚠️ No Firestore user found for profileId: $profileId",
                  );
                }

                posts.add(postModel);
              } catch (e, st) {
                print("❌ Error parsing post entry: $e\n$st");
                debugPrint("❌ Error parsing post entry: $e\n$st");
              }
            }

            posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return posts;
          } catch (e, st) {
            print("❌ getPostsStream failed: $e\n$st");
            debugPrint("❌ getPostsStream failed: $e\n$st");
            return <PicPostModel>[];
          }
        })
        .handleError((e, st) {
          debugPrint("❌ STREAM error in getPostsStream: $e\n$st");
        });
  }
}
