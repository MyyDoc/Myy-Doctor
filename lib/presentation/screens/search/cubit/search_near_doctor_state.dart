part of 'search_near_doctor_cubit.dart';

sealed class SearchNearDoctorState extends Equatable {
  const SearchNearDoctorState();

  @override
  List<Object> get props => [];
}

final class SearchNearDoctorInitial extends SearchNearDoctorState {}

final class SearchErrorState extends SearchNearDoctorState{
  final String message;
  const SearchErrorState({required this.message});
}

final class SearchDoctorSuccsussState extends SearchNearDoctorState{
  final List <DoctorSearchModel> doctors;
  const SearchDoctorSuccsussState({required this.doctors});
}

final class SearchingDoctorState extends SearchNearDoctorState{
  
}