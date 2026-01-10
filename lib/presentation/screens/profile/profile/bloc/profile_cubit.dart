// profile_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../data/user/user_model.dart';
import '../../../../../domain/firebase_service.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FirebaseService _firebaseService;

  ProfileCubit(this._firebaseService) : super(ProfileInitial());

  Future<void> fetchCurrentUserProfile() async {
    emit(ProfileLoading());

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(const ProfileError('No user logged in'));
        return;
      }

      final userDoc = await _firebaseService.usersCollection.doc(currentUser.uid).get();

      if (!userDoc.exists) {
        emit(const ProfileError('User profile not found'));
        return;
      }

      final user = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);

      emit(ProfileLoaded(user: user));
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  void listenToUserProfile() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _firebaseService.usersCollection.doc(currentUser.uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final user = UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
        emit(ProfileLoaded(user: user));
      }
    });
  }
}