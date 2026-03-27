import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:myydoctor/services/compress_image.dart';

part 'save_profile_pic_state.dart';

class SaveProfilePicCubit extends Cubit<SaveProfilePicState> {
  SaveProfilePicCubit() : super(SaveProfilePicInitial());

  uploadImage(XFile file) async {
    File? compressedFile;

    try {
      emit(SaveProfilePicCubitLoadingState());

      final uid = FirebaseAuth.instance.currentUser!.uid;

      // 👉 Try compress
      compressedFile = await compressImage(file.path);
      final uploadFile = compressedFile ?? File(file.path);

      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_images")
          .child("$uid.jpg");

      await ref.putFile(
        uploadFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadurl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        "profilePicture": downloadurl,
      });

      // ✅ Delete compressed file after success
      if (compressedFile != null && await compressedFile.exists()) {
        await compressedFile.delete();
      }

      emit(ProfilePicSavedSuccessState());
    } catch (e) {
      // ❌ Delete compressed file if error occurs
      if (compressedFile != null && await compressedFile.exists()) {
        await compressedFile.delete();
      }

      emit(ProfilePicSavedFailureState(error: e.toString()));
    }
  }
}
