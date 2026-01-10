
part of 'fetch_user_details_cubit.dart';

abstract class FetchUserDetailsState extends Equatable {
  const FetchUserDetailsState();

  @override
  List<Object?> get props => [];
}

class FetchUserDetailsInitial extends FetchUserDetailsState {}

class FetchUserDetailsLoading extends FetchUserDetailsState {}

class FetchUserDetailsSuccess extends FetchUserDetailsState {
  final UserModel user;

  const FetchUserDetailsSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class FetchUserDetailsNotFound extends FetchUserDetailsState {
  final String message;

  const FetchUserDetailsNotFound(this.message);

  @override
  List<Object?> get props => [message];
}

class FetchUserDetailsError extends FetchUserDetailsState {
  final String message;

  const FetchUserDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}