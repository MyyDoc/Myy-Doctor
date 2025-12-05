import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

part 'save_profile_pic_state.dart';

class SaveProfilePicCubit extends Cubit<SaveProfilePicState> {
  SaveProfilePicCubit() : super(SaveProfilePicInitial());

  uploadImage(XFile file)async{
    try {
      emit(SaveProfilePicCubitLoadingState());
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref =  FirebaseStorage.instance.ref().child("profile_images").child("$uid.jpg");
      await ref.putFile(File(file.path));

      final downloadurl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(uid).update({"profilePicture" : downloadurl});

      emit(ProfilePicSavedSuccessState());
    } catch (e) {
      emit(ProfilePicSavedFailureState(error: e.toString()));
    }
  }
}
