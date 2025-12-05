part of 'save_age_bloc.dart';

@immutable
sealed class SaveAgeEvent {}

class SaveAgeButtonPressedEvent extends SaveAgeEvent {
  final int age;
  SaveAgeButtonPressedEvent({required this.age});
}