import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

part 'save_profile_preference_state.dart';

class SaveProfilePreferenceCubit extends Cubit<SaveProfilePreferenceState> {
  SaveProfilePreferenceCubit() : super(SaveProfilePreferenceInitial());

  static XFile? profileImage;
  static int? age;
  static String? occupation;
  static String? fieldOfWork;
  static String? doctorRegistrationNumber;

  

  // ------------------------------------------
  // CREATE first-time preference (overwrite/merge)
  // ------------------------------------------
  Future<void> createAndsavePreference(String preference, Widget page) async {
    emit(SavingPrefilePreferenceLoadingState());
    

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        emit(SavingProfilePreferenceFailureState(error: "User not logged in"));
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(
        {
          "userPreference": [preference],
        },
        SetOptions(merge: true),
      );

      emit(SavingProfilePreferenceSuccessState(page: page));
    }

    on FirebaseAuthException catch (e) {
      emit(SavingProfilePreferenceFailureState(error: "Auth error: ${e.message}"));
    }

    on FirebaseException catch (e) {
      emit(SavingProfilePreferenceFailureState(error: "Firestore error: ${e.message}"));
    }

    catch (e) {
      emit(SavingProfilePreferenceFailureState(error: "Unexpected error: $e"));
    }
  }

  // ------------------------------------------
  // ADD new preference to array (no duplicates)
  // ------------------------------------------
  Future<void> savePreference(String preference, Widget page) async {
    emit(SavingPrefilePreferenceLoadingState());

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        emit(SavingProfilePreferenceFailureState(error: "User not logged in"));
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'userPreference': FieldValue.arrayUnion([preference]),
      });

      emit(SavingProfilePreferenceSuccessState(page: page));
    }

    on FirebaseAuthException catch (e) {
      emit(SavingProfilePreferenceFailureState(error: "Auth error: ${e.message}"));
    }

    on FirebaseException catch (e) {
      // Special case: doc does not exist
      if (e.code == 'not-found') {
        emit(SavingProfilePreferenceFailureState(
            error: "User document does not exist. Use createAndsavePreference() first."));
      } else {
        emit(SavingProfilePreferenceFailureState(error: "Firestore error: ${e.message}"));
      }
    }

    catch (e) {
      emit(SavingProfilePreferenceFailureState(error: "Unexpected error: $e"));
    }
  }
}
