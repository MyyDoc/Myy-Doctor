import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';

part 'upload_reel_state.dart';

class UploadReelCubit extends Cubit<UploadReelState> {
  UploadReelCubit() : super(UploadReelInitial());

  StreamSubscription<TaskSnapshot>? _uploadSubscription;

  Future<void> uploadReel({
    required String videoPath,
    required String caption,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    emit(UploadingReelProgressState(progress: 0));

    try {
      final uid = user?.uid;
      if (uid == null) {
        emit(UploadReelErrorState(error: 'User not logged in'));
        return;
      }

      final file = File(videoPath);

      // DB refs
      final reelRef =
          FirebaseDatabase.instance.ref().child('reels').child(uid);
      final newReelRef = reelRef.push();
      final reelId = newReelRef.key;

      if (reelId == null) {
        emit(UploadReelErrorState(error: 'Failed to generate reel ID'));
        return;
      }

      // Storage ref
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('reels')
          .child(uid)
          .child('$reelId.mp4');

      // Start upload
      final uploadTask = storageRef.putFile(file);

      // Cancel any previous listener
      await _uploadSubscription?.cancel();

      // Listen to progress
      _uploadSubscription = uploadTask.snapshotEvents.listen(
        (snapshot) {
          final progress =
              snapshot.bytesTransferred / snapshot.totalBytes;
          emit(UploadingReelProgressState(progress: progress));
        },
        onError: (e) {
          emit(UploadReelErrorState(error: e.toString()));
        },
      );

      // Wait for completion
      final completedSnapshot = await uploadTask;
      final downloadUrl = await completedSnapshot.ref.getDownloadURL();

      // Save to DB
      await newReelRef.set({
        'reelId': reelId,
        'ownerId': uid,
        'videoUrl': downloadUrl,
        'caption': caption,
        'createdAt': ServerValue.timestamp,
        'likeCount': 0,
        'commentCount': 0,
        'likes': {},
        'comments': {},
      });

      // Cleanup
      await _uploadSubscription?.cancel();
      _uploadSubscription = null;

      emit(UploadReelSuccessState());
    } catch (e) {
      await _uploadSubscription?.cancel();
      _uploadSubscription = null;
      emit(UploadReelErrorState(error: e.toString()));
    }
  }

  Future<void> deleteReel({required String reelId}) async {
    final user = FirebaseAuth.instance.currentUser;

    emit(UploadReelLoadingState());

    try {
      final uid = user?.uid;
      if (uid == null) {
        emit(UploadReelErrorState(error: 'User not logged in'));
        return;
      }

      final reelRef = FirebaseDatabase.instance
          .ref()
          .child('reels')
          .child(uid)
          .child(reelId);

      final snapshot = await reelRef.get();
      if (!snapshot.exists) {
        emit( UploadReelErrorState(error: 'Reel not found'));
        return;
      }

      final data = snapshot.value as Map;
      final videoUrl = data['videoUrl'];

      if (videoUrl != null) {
        final storageRef =
            FirebaseStorage.instance.refFromURL(videoUrl);
        await storageRef.delete();
      }

      await reelRef.remove();

      emit(UploadReelSuccessState());
    } catch (e) {
      emit(UploadReelErrorState(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _uploadSubscription?.cancel();
    return super.close();
  }
}
