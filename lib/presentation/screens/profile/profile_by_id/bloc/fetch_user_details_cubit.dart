import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myydoctor/data/user/user_model.dart';

part 'fetch_user_details_state.dart';

class FetchUserDetailsCubit extends Cubit<FetchUserDetailsState> {
  FetchUserDetailsCubit() : super(FetchUserDetailsInitial());

  // Optional: debug state changes
  @override
  void onChange(Change<FetchUserDetailsState> change) {
    super.onChange(change);
    print('FetchUserDetails → ${change.currentState.runtimeType} → ${change.nextState.runtimeType}');
  }

  /// Fetch user details by any user ID
  Future<void> fetchUserById(String userId) async {
    if (userId.isEmpty) {
      emit(const FetchUserDetailsError('User ID is required'));
      return;
    }

    emit(FetchUserDetailsLoading());

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        emit(const FetchUserDetailsNotFound('User not found'));
        return;
      }

      final data = docSnapshot.data()!;
      final user = UserModel.fromJson(data);

      emit(FetchUserDetailsSuccess(user: user));
    } on FirebaseException catch (e) {
      emit(FetchUserDetailsError('Firebase error: ${e.message ?? e.code}'));
    } catch (e) {
      emit(FetchUserDetailsError('Failed to load user: $e'));
    }
  }

  /// Optional: Real-time listening to user changes
  StreamSubscription<DocumentSnapshot>? _subscription;

  void listenToUser(String userId) {
    _subscription?.cancel();

    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

    _subscription = docRef.snapshots().listen((snapshot) {
      if (!snapshot.exists) {
        emit(const FetchUserDetailsNotFound('User not found'));
        return;
      }

      final data = snapshot.data()!;
      final user = UserModel.fromJson(data);

      emit(FetchUserDetailsSuccess(user: user));
    }, onError: (error) {
      emit(FetchUserDetailsError('Stream error: $error'));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}