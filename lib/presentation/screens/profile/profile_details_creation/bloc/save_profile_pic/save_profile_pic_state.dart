part of 'save_profile_pic_cubit.dart';

@immutable
sealed class SaveProfilePicState {}

final class SaveProfilePicInitial extends SaveProfilePicState {}

final class ProfilePicSavedSuccessState extends SaveProfilePicState{}

final class ProfilePicSavedFailureState extends SaveProfilePicState{
  final String error;
  ProfilePicSavedFailureState({required this.error});
}

final class SaveProfilePicCubitLoadingState extends SaveProfilePicState{}