import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myydoctor/data/posts/pic_post_model.dart';

class PicPostRepository {
  // ---------- SINGLETON ----------
  static final PicPostRepository _instance = PicPostRepository._internal();
  factory PicPostRepository() => _instance;
  PicPostRepository._internal();
  // --------------------------------

  StreamController<List<PicPostModel>>? _controller;
  StreamSubscription<DatabaseEvent>? _dbSubscription;
  String? _lastStreamKey;

  Stream<List<PicPostModel>> getPostsStream({required bool useOwnerProfile}) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    final streamKey = useOwnerProfile ? "GLOBAL" : "USER-$userId";

    // Reset when switching types
    if (_lastStreamKey != streamKey) {
      _dbSubscription?.cancel();
      _controller?.close();
      _controller = StreamController<List<PicPostModel>>.broadcast();
      _lastStreamKey = streamKey;
    }

    _controller ??= StreamController<List<PicPostModel>>.broadcast();

    _dbSubscription?.cancel();
    _dbSubscription = null;

    final ref = useOwnerProfile
        ? FirebaseDatabase.instance.ref().child("posts")
        : FirebaseDatabase.instance.ref().child("posts/$userId");

    _dbSubscription = ref.onValue.listen((event) async {
      final rawData = event.snapshot.value;

      if (rawData == null || rawData is! Map) {
        _controller!.add([]);
        return;
      }

      List<PicPostModel> posts = [];

      // GLOBAL FEED
      if (useOwnerProfile) {
        final allUsersMap = Map<dynamic, dynamic>.from(rawData);

        for (var userEntry in allUsersMap.entries) {
          if (userEntry.value is! Map) continue;

          final userPostsMap = Map<dynamic, dynamic>.from(userEntry.value);

          for (var postEntry in userPostsMap.entries) {
            if (postEntry.value is! Map) continue;

            final postModel =
                PicPostModel.fromMap(Map<String, dynamic>.from(postEntry.value));

            final ownerDoc = await FirebaseFirestore.instance
                .collection("users")
                .doc(postModel.ownerId)
                .get();

            if (ownerDoc.exists) {
              postModel.name = ownerDoc["fullName"];
              postModel.profileImageUrl = ownerDoc["profilePicture"];
            }

            posts.add(postModel);
          }
        }
      }
      // USER FEED
      else {
        final postsMap = Map<dynamic, dynamic>.from(rawData);

        for (var entry in postsMap.entries) {
          if (entry.value is! Map) continue;

          final postModel =
              PicPostModel.fromMap(Map<String, dynamic>.from(entry.value));

          final userDoc = await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();

          if (userDoc.exists) {
            postModel.name = userDoc["fullName"];
            postModel.profileImageUrl = userDoc["profilePicture"];
          }

          posts.add(postModel);
        }
      }

      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _controller!.add(posts);
    });

    return _controller!.stream;
  }

  void dispose() {
    _dbSubscription?.cancel();
    _controller?.close();
    _controller = null;
    _dbSubscription = null;
    _lastStreamKey = null;
  }
}
