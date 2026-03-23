import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';
import 'package:myydoctor/services/compress_image.dart';
part 'upload_story_state.dart';

class UploadStoryCubit extends Cubit<UploadStoryState> {
  UploadStoryCubit() : super(UploadStoryInitial());

  uploadStory({required String editedFilePath}) async {
    final user = FirebaseAuth.instance.currentUser;

    emit(UploadStoryLoading());

    try {
      final uid = user?.uid;
      if (uid == null) {
        emit(UploadStoryError(error: 'User not logged in'));
        return;
      }

      final originalFile = File(editedFilePath);
      if (!await originalFile.exists()) {
        emit(UploadStoryError(error: 'Edited file not found'));
        return;
      }

      /// 🔥 CALL YOUR EXISTING COMPRESSION FUNCTION
      File fileToUpload = originalFile;

      final compressedFile = await compressImage(editedFilePath);

      if (compressedFile != null && await compressedFile.exists()) {
        fileToUpload = compressedFile;
      }

      // Generate unique story ID
      final storyRef =
          FirebaseDatabase.instance.ref().child('stories').child(uid);
      final newStoryRef = storyRef.push();
      final storyId = newStoryRef.key;

      if (storyId == null) {
        emit(UploadStoryError(error: 'Failed to generate story ID'));
        return;
      }

      // Upload image to Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('stories')
          .child(uid)
          .child('$storyId.jpg');

      final uploadTask = await storageRef.putFile(fileToUpload);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Save story data
      final storyData = {
        'storyId': storyId,
        'ownerId': uid,
        'imageUrl': downloadUrl,
        'createdAt': ServerValue.timestamp,
      };

      await newStoryRef.set(storyData);

      emit(UploadStorySuccess());
    } catch (e) {
      emit(UploadStoryError(error: e.toString()));
      print('Story upload error: $e');
    }
  }

  deleteStory({required String storyId}) async {
    final user = FirebaseAuth.instance.currentUser;

    emit(UploadStoryLoading());

    try {
      final uid = user?.uid;
      if (uid == null) {
        emit(UploadStoryError(error: 'User not logged in'));
        return;
      }

      final storyRef = FirebaseDatabase.instance
          .ref()
          .child('stories')
          .child(uid)
          .child(storyId);

      final snapshot = await storyRef.get();
      if (!snapshot.exists) {
        emit(UploadStoryError(error: 'Story not found'));
        return;
      }

      final data = snapshot.value as Map;
      final imageUrl = data['imageUrl'] as String?;

      if (imageUrl != null) {
        final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await storageRef.delete();
      }

      await storyRef.remove();

      emit(UploadStorySuccess());
    } catch (e) {
      emit(UploadStoryError(error: e.toString()));
    }
  }
}