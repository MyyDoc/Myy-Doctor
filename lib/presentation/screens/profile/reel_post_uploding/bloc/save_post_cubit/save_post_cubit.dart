import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'save_post_state.dart';

class SavePostCubit extends Cubit<SavePostState> {
  SavePostCubit() : super(SavePostInitial());

  Future<void> toggleSave({
    required String postId,
    required String ownerId,
    required bool isCurrentlySaved,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const SavePostError('User not logged in'));
      return;
    }

    emit(SavePostLoading());

    try {
      final savedRef = FirebaseDatabase.instance
          .ref()
          .child('savedPosts')
          .child(user.uid)
          .child(postId);

      if (isCurrentlySaved) {
        // Unsave
        await savedRef.remove();
        emit(const SavePostSuccess(isSaved: false));
      } else {
        // Save
        await savedRef.set({
          'postId': postId,
          'ownerId': ownerId,
          'savedAt': ServerValue.timestamp,
        });
        emit(const SavePostSuccess(isSaved: true));
      }
    } catch (e) {
      emit(SavePostError(e.toString()));
    }
  }

  Future<bool> isPostSaved(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final snapshot = await FirebaseDatabase.instance
        .ref()
        .child('savedPosts')
        .child(user.uid)
        .child(postId)
        .get();

    return snapshot.exists;
  }
}