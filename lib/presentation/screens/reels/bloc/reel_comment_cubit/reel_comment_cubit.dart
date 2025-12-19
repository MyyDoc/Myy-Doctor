import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myydoctor/data/user/reel_comment_model.dart';

part 'reel_comment_state.dart';

class ReelCommentCubit extends Cubit<ReelCommentState> {
  ReelCommentCubit() : super(ReelCommentInitial());

  StreamSubscription<DatabaseEvent>? _subscription;

  /// ─────────────────────────────────────────────
  /// FETCH COMMENTS (REALTIME)
  /// ─────────────────────────────────────────────
  void fetchComments(String reelId) {

    _subscription?.cancel();

    final ref = FirebaseDatabase.instance
        .ref('reelComments/$reelId')
        .orderByChild('createdAt');

    _subscription = ref.onValue.listen(
      (event) {
        final data = event.snapshot.value;

        if (data == null || data is! Map) {
          emit(CommentLoaded([]));
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
        emit(CommentLoaded(comments));
      },
      onError: (e) {
        emit(CommentError(e.toString()));
      },
    );
  }

  /// ─────────────────────────────────────────────
  /// POST COMMENT
  /// ─────────────────────────────────────────────
  Future<void> postComment({
    required String reelId,
    required String reelOwnerId,
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
          FirebaseDatabase.instance.ref().child('reelComments').push().key;

      if (commentId == null) return;

      final commentData = {
        'commentId': commentId,
        'reelId': reelId,
        'userId': uid,
        'userName': userData['fullName'] ?? '',
        'userProfilePicUrl': userData['profilePicture'] ?? '',
        'text': text.trim(),
        'createdAt': ServerValue.timestamp,
      };

      final updates = {
        'reelComments/$reelId/$commentId': commentData,
        'reelsFeed/$reelId/commentCount': ServerValue.increment(1),
        'userReels/$reelOwnerId/$reelId/commentCount':
            ServerValue.increment(1),
      };

      await FirebaseDatabase.instance.ref().update(updates);
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  /// ─────────────────────────────────────────────
  /// DELETE COMMENT (OWNER ONLY)
  /// ─────────────────────────────────────────────
  Future<void> deleteComment({
    required String reelId,
    required String reelOwnerId,
    required String commentId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final updates = {
        'reelComments/$reelId/$commentId': null,
        'reelsFeed/$reelId/commentCount': ServerValue.increment(-1),
        'userReels/$reelOwnerId/$reelId/commentCount':
            ServerValue.increment(-1),
      };

      await FirebaseDatabase.instance.ref().update(updates);
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
