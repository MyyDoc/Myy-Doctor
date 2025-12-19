import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myydoctor/data/user/reel_comment_model.dart';

part 'post_comment_state.dart';

class PostCommentCubit extends Cubit<PostCommentState> {
  PostCommentCubit() : super(PostCommentInitial());

  StreamSubscription<DatabaseEvent>? _subscription;

  /// ─────────────────────────────────────────────
  /// FETCH COMMENTS (REALTIME)
  /// ─────────────────────────────────────────────
  void fetchComments(String postId) {
    _subscription?.cancel();

    final ref = FirebaseDatabase.instance
        .ref('postComments/$postId')
        .orderByChild('createdAt');

    _subscription = ref.onValue.listen(
      (event) {
        final data = event.snapshot.value;

        if (data == null || data is! Map) {
          emit(PostCommentLoaded([]));
          return;
        }

        final List<ReelComment> comments = [];

        final map = Map<dynamic, dynamic>.from(data);
        for (final value in map.values) {
          if (value is Map) {
            comments.add(
              ReelComment.fromMap(
                Map<String, dynamic>.from(value),
              ),
            );
          }
        }

        comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        emit(PostCommentLoaded(comments));
      },
      onError: (e) {
        emit(PostCommentError(e.toString()));
      },
    );
  }

  /// ─────────────────────────────────────────────
  /// POST COMMENT
  /// ─────────────────────────────────────────────
  Future<void> postComment({
    required String postId,
    required String postOwnerId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) return;

      final userData = userDoc.data()!;

      final commentId =
          FirebaseDatabase.instance.ref().child('postComments').push().key;

      if (commentId == null) return;

      final commentData = {
        'commentId': commentId,
        'postId': postId,
        'userId': uid,
        'userName': userData['fullName'] ?? '',
        'userProfilePicUrl': userData['profilePicture'] ?? '',
        'text': text.trim(),
        'createdAt': ServerValue.timestamp,
      };

      final updates = {
        'postComments/$postId/$commentId': commentData,
        'posts/$postOwnerId/$postId/commentCount':
            ServerValue.increment(1),
      };

      await FirebaseDatabase.instance.ref().update(updates);
    } catch (e) {
      emit(PostCommentError(e.toString()));
    }
  }

  /// ─────────────────────────────────────────────
  /// DELETE COMMENT (OWNER ONLY)
  /// ─────────────────────────────────────────────
  Future<void> deleteComment({
    required String postId,
    required String postOwnerId,
    required String commentId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final updates = {
        'postComments/$postId/$commentId': null,
        'posts/$postOwnerId/$postId/commentCount':
            ServerValue.increment(-1),
      };

      await FirebaseDatabase.instance.ref().update(updates);
    } catch (e) {
      emit(PostCommentError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
