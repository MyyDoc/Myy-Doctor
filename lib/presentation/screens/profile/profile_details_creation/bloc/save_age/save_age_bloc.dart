import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'save_age_event.dart';
part 'save_age_state.dart';

class SaveAgeBloc extends Bloc<SaveAgeEvent, SaveAgeState> {
  SaveAgeBloc() : super(SaveAgeInitial()) {
    on<SaveAgeButtonPressedEvent>((event, emit) async {
      emit(SaveAgeLoading());

      try {
        print(event.age);
        final uid = FirebaseAuth.instance.currentUser?.uid;

        if (uid == null) {
          emit(SavingAgeFailureState(error:  "User not logged in"));
          return;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({
          'age': event.age,
        }, SetOptions(merge: true));   // safest for first time

        emit(SavingAgeSuccessState());
      }

      on FirebaseException catch (e) {
        print(e);
        // Firestore-specific error
        emit(SavingAgeFailureState(error: "Firestore error: ${e.message}"));
      }

      catch (e) {
        print(e);
        // Any other error
        emit(SavingAgeFailureState(error: "Unknown error: $e"));
      }
    });
  }
}
