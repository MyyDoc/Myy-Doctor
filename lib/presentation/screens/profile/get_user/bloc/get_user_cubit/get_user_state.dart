part of 'get_user_cubit.dart';

abstract class FetchUserState extends Equatable {
  const FetchUserState();

  @override
  List<Object> get props => [];
}

class FetchUserInitial extends FetchUserState {}

class FetchUserLoading extends FetchUserState {}

class FetchUserSuccess extends FetchUserState {
  final Map<String, dynamic> userData;
  final bool isDoctor;

  const FetchUserSuccess({
    required this.userData,
    required this.isDoctor,
  });

  @override
  List<Object> get props => [userData, isDoctor];
}

class FetchUserError extends FetchUserState {
  final String error;

  const FetchUserError(this.error);

  @override
  List<Object> get props => [error];
}