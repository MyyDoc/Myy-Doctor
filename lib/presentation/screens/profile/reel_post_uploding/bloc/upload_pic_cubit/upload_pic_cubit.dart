import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';

part 'upload_pic_state.dart';

class UploadPicCubit extends Cubit<UploadPicState> {
  UploadPicCubit() : super(UploadPicInitial());

  uploadPic({required String picPath, required String caption}) async {
    final user = FirebaseAuth.instance.currentUser;

    emit(UploadLoadingState());

    try {
      final uid = user?.uid;
      if (uid == null) {
        print('user not logged in');
        emit(UploadPicErrorState(error: 'User not logged in'));
        return;
      }
      final file = File(picPath);

      final postRef = FirebaseDatabase.instance.ref().child('posts').child(uid);
      final newPostRef = postRef.push();
      final postId = newPostRef.key;

      if (postId == null) {
        emit(UploadPicErrorState(error: 'Failed to generate post ID'));
        return;
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('posts')
          .child(uid)
          .child('$postId.jpg');

      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      final postData = {
        'postId': postId,
        'ownerId': uid,
        'imageUrl': downloadUrl,
        'caption': caption,
        'createdAt': ServerValue.timestamp,
        'likeCount': 0,
        'commentCount': 0,
        'likes': {}, // empty map for future likes
        'comments': {}, // empty map for future comments
      };

      await newPostRef.set(postData);
      emit(UploadPicSuccessState());
    } catch (e) {
      emit(UploadPicErrorState(error: e.toString()));
      print(e);
    }
  }

  deletePost({required String postId}) async {
  final user = FirebaseAuth.instance.currentUser;

  emit(UploadLoadingState());

  try {
    final uid = user?.uid;
    if (uid == null) {
      emit(UploadPicErrorState(error: 'User not logged in'));
      return;
    }

    final postRef = FirebaseDatabase.instance.ref()
        .child('posts')
        .child(uid)
        .child(postId);

    // 1. Fetch the post to get imageUrl
    final snapshot = await postRef.get();
    if (!snapshot.exists) {
      emit(UploadPicErrorState(error: 'Post not found'));
      return;
    }

    final data = snapshot.value as Map;
    final imageUrl = data['imageUrl'];

    // 2. Delete image from Firebase Storage
    if (imageUrl != null) {
      final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
    }

    // 3. Delete post data from Realtime Database
    await postRef.remove();

    emit(UploadPicSuccessState());
  } catch (e) {
    emit(UploadPicErrorState(error: e.toString()));
  }
}

}
