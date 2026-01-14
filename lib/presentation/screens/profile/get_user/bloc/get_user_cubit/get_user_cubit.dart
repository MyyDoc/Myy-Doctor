import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'get_user_state.dart';

class FetchUserCubit extends Cubit<FetchUserState> {
  FetchUserCubit() : super(FetchUserInitial());

  @override
  void onChange(Change<FetchUserState> change) {
    super.onChange(change);
    print('User State Change: ${change.currentState} → ${change.nextState}');
  }

  Future<void> fetchUser() async {
    emit(FetchUserLoading());

    try {
      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        emit(const FetchUserError('User not logged in'));
        return;
      }

      final uid = authUser.uid;

      // ───────────────────────────────────────────────
      // This is the line you wanted:
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
      // ───────────────────────────────────────────────

      final docSnapshot = await userDocRef.get();

      if (!docSnapshot.exists) {
        print('No user document found for uid: $uid');
        emit(const FetchUserSuccess(userData: {}, isDoctor: false));
        return;
      }

      // Get the full data as Map<String, dynamic>
      final userData = docSnapshot.data() as Map<String, dynamic>;

      // For better debugging — print everything nicely
      print('=== User Data from Firestore (uid: $uid) ===');
      userData.forEach((key, value) {
        print('  $key: $value');
      });

      // Calculate isDoctor
      bool isDoctor = false;
      if (userData.containsKey('userPreference') &&
          userData['userPreference'] is List &&
          (userData['userPreference'] as List).isNotEmpty) {
        final preferenceList = userData['userPreference'] as List<dynamic>;
        isDoctor = preferenceList[0].toString().toLowerCase() == 'doctor';
      }

      print('Is Doctor: $isDoctor');

      emit(FetchUserSuccess(userData: userData, isDoctor: isDoctor));
    } catch (e) {
      print('Error fetching user from Firestore: $e');
      emit(FetchUserError(e.toString()));
    }
  }

  // Optional: Real-time listener version
  Future<void> listenToUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) {
        emit(const FetchUserSuccess(userData: {}, isDoctor: false));
        return;
      }

      final userData = snapshot.data()!;
      bool isDoctor = false;
      if (userData['userPreference'] is List &&
          (userData['userPreference'] as List).isNotEmpty) {
        isDoctor = (userData['userPreference'] as List)[0].toString().toLowerCase() == 'doctor';
      }

      emit(FetchUserSuccess(userData: userData, isDoctor: isDoctor));
    }, onError: (error) {
      emit(FetchUserError(error.toString()));
    });
  }
}