import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';
import 'package:myydoctor/services/compress_video.dart';
import 'package:video_compress/video_compress.dart';

part 'upload_reel_state.dart';

class UploadReelCubit extends Cubit<UploadReelState> {
  UploadReelCubit() : super(UploadReelInitial());

  StreamSubscription<TaskSnapshot>? _uploadSubscription;

  Future<void> uploadReel({
  required String videoPath,
  required String caption,
}) async {
  emit(UploadingReelProgressState(progress: 0));

  File? compressedFile;

  try {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid == null) {
      emit(UploadReelErrorState(error: 'User not logged in'));
      return;
    }

    /// 🧠 1️⃣ COMPRESS VIDEO (background)
    compressedFile = await compressVideo(videoPath);

    if (compressedFile == null) {
      emit(UploadReelErrorState(error: 'Video compression failed'));
      return;
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      emit(UploadReelErrorState(error: 'User profile not found'));
      return;
    }

    final userData = userDoc.data()!;

    final ownerName = userData['fullName']?.toString() ?? '';
    final ownerProfilePicUrl =
        userData['profilePicture']?.toString() ?? '';

    // Generate reelId
    final reelId = FirebaseDatabase.instance.ref().push().key;

    if (reelId == null) {
      emit(UploadReelErrorState(error: 'Failed to generate reel ID'));
      return;
    }

    /// 🚀 2️⃣ UPLOAD COMPRESSED VIDEO
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('reels')
        .child(uid)
        .child('$reelId.mp4');

    final uploadTask = storageRef.putFile(compressedFile);

    await _uploadSubscription?.cancel();

    _uploadSubscription = uploadTask.snapshotEvents.listen((snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      emit(UploadingReelProgressState(progress: progress));
    });

    final completed = await uploadTask;
    final downloadUrl = await completed.ref.getDownloadURL();

    final reelData = {
      'reelId': reelId,
      'ownerId': uid,
      'ownerName': ownerName,
      'ownerProfilePicUrl': ownerProfilePicUrl,
      'videoUrl': downloadUrl,
      'caption': caption,
      'createdAt': ServerValue.timestamp,
      'likeCount': 0,
      'commentCount': 0,
    };

    final userReelRef =
        FirebaseDatabase.instance.ref('userReels/$uid/$reelId');

    final feedReelRef =
        FirebaseDatabase.instance.ref('reelsFeed/$reelId');

    await Future.wait([
      userReelRef.set(reelData),
      feedReelRef.set(reelData),
    ]);

    await _uploadSubscription?.cancel();
    _uploadSubscription = null;

    emit(UploadReelSuccessState());
  } catch (e) {
    await _uploadSubscription?.cancel();
    _uploadSubscription = null;

    emit(UploadReelErrorState(error: e.toString()));
  } finally {
    /// 🧹 ALWAYS CLEAN TEMP FILE
    try {
      if (compressedFile != null && await compressedFile.exists()) {
        await compressedFile.delete();
      }

      // also cleanup package temp files
      await VideoCompress.deleteAllCache();
    } catch (_) {
      // ignore cleanup errors
    }
  }
}

 Future<void> deleteReel({
  required String reelId,
  required String ownerId,
}) async {
  emit(UploadReelLoadingState());

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid != ownerId) {
      emit(UploadReelErrorState(error: 'Unauthorized'));
      return;
    }

    final userReelRef =
        FirebaseDatabase.instance.ref('userReels/$ownerId/$reelId');

    final snapshot = await userReelRef.get();
    if (!snapshot.exists) {
      emit(UploadReelErrorState(error: 'Reel not found'));
      return;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final videoUrl = data['videoUrl'];

    /// 🧹 DELETE VIDEO FROM STORAGE
    if (videoUrl != null && videoUrl.toString().isNotEmpty) {
      await FirebaseStorage.instance.refFromURL(videoUrl).delete();
    }

    /// 🔥 ATOMIC MULTI-LOCATION DELETE
    final Map<String, Object?> updates = {
      'userReels/$ownerId/$reelId': null,
      'reelsFeed/$reelId': null,
      'reelComments/$reelId': null, // ✅ FIX: delete all comments
    };

    await FirebaseDatabase.instance.ref().update(updates);

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
