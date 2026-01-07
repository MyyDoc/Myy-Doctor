import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        emit(UploadPicErrorState(error: 'User not logged in'));
        return;
      }

      // 1️⃣ Fetch user profile from Firestore
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        emit(UploadPicErrorState(error: 'User profile not found'));
        return;
      }

      final userData = userDoc.data()!;

      final file = File(picPath);

      // 2️⃣ Create post ID
      final postRef = FirebaseDatabase.instance.ref('posts/$uid').push();
      final postId = postRef.key;

      if (postId == null) {
        emit(UploadPicErrorState(error: 'Failed to generate post ID'));
        return;
      }

      // 3️⃣ Upload image
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('posts')
          .child(uid)
          .child('$postId.jpg');

      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // 4️⃣ Save post WITH user data
      final postData = {
        'username' : userData['username'],
        'postId': postId,
        'ownerId': uid,
        'fullName': userData['fullName'] ?? '',
        'profileImageUrl': userData['profilePicture'] ?? '',
        'imageUrl': downloadUrl,
        'caption': caption,
        'createdAt': ServerValue.timestamp,
        'likeCount': 0,
        'commentCount': 0,
      };

      await postRef.set(postData);

      emit(UploadPicSuccessState());
    } catch (e) {
      emit(UploadPicErrorState(error: e.toString()));
    }
  }

  Future<void> deletePost({required String postId}) async {
    final user = FirebaseAuth.instance.currentUser;

    emit(UploadLoadingState());

    try {
      final uid = user?.uid;
      if (uid == null) {
        emit(UploadPicErrorState(error: 'User not logged in'));
        return;
      }

      final db = FirebaseDatabase.instance.ref();

      final postRef = db.child('posts').child(uid).child(postId);

      // 1️⃣ Fetch post to get imageUrl
      final snapshot = await postRef.get();
      if (!snapshot.exists) {
        emit(UploadPicErrorState(error: 'Post not found'));
        return;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final imageUrl = data['imageUrl'];

      // 2️⃣ Delete image from Firebase Storage
      if (imageUrl != null && imageUrl is String && imageUrl.isNotEmpty) {
        final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await storageRef.delete();
      }

      // 3️⃣ Atomic delete: post + comments
      final updates = <String, dynamic>{
        'posts/$uid/$postId': null,
        'postComments/$postId': null,
      };

      await db.update(updates);

      emit(UploadPicSuccessState());
    } catch (e) {
      emit(UploadPicErrorState(error: e.toString()));
    }
  }
}
