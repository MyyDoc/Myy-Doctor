part of 'save_profile_preference_cubit.dart';

@immutable
sealed class SaveProfilePreferenceState {}

final class SaveProfilePreferenceInitial extends SaveProfilePreferenceState {}

final class SavingProfilePreferenceSuccessState extends SaveProfilePreferenceState{
  final Widget page;
  SavingProfilePreferenceSuccessState({required this.page});
}

final class SavingProfilePreferenceFailureState extends SaveProfilePreferenceState{
  final String error;
  SavingProfilePreferenceFailureState({required this.error});
}

final class SavingPrefilePreferenceLoadingState extends SaveProfilePreferenceState{}