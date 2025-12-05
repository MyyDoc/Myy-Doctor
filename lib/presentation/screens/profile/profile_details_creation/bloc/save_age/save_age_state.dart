part of 'save_age_bloc.dart';

@immutable
sealed class SaveAgeState {}

final class SaveAgeInitial extends SaveAgeState {}

final class SavingAgeSuccessState extends SaveAgeState {
}

final class SavingAgeFailureState extends SaveAgeState{
  final String error;
  SavingAgeFailureState({required this.error});
}
final class SaveAgeLoading extends SaveAgeState {}