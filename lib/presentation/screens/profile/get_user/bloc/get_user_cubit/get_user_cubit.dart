import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:equatable/equatable.dart';

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
      final userRef = FirebaseDatabase.instance.ref().child('users').child(uid);

      final snapshot = await userRef.get();

      if (!snapshot.exists) {
        emit(const FetchUserSuccess(userData: {}, isDoctor: false));
        return;
      }

      final Map<dynamic, dynamic> rawData = snapshot.value as Map<dynamic, dynamic>;
      final Map<String, dynamic> userData = rawData.cast<String, dynamic>();

      bool isDoctor = false;
      if (userData.containsKey('userPreference') &&
          userData['userPreference'] is List &&
          (userData['userPreference'] as List).isNotEmpty) {
        final preferenceList = userData['userPreference'] as List<dynamic>;
        isDoctor = preferenceList[0] == 'Doctor';
      }

      emit(FetchUserSuccess(userData: userData, isDoctor: isDoctor));
    } catch (e) {
      emit(FetchUserError(e.toString()));
    }
  }
}