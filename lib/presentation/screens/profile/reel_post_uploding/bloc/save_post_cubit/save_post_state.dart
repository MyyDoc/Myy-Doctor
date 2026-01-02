part of 'save_post_cubit.dart';

@immutable
sealed class SavePostState extends Equatable {
  const SavePostState();

  @override
  List<Object> get props => [];
}

final class SavePostInitial extends SavePostState {}

final class SavePostLoading extends SavePostState {}

final class SavePostError extends SavePostState {
  final String message;
  const SavePostError(this.message);

  @override
  List<Object> get props => [message];
}

final class SavePostSuccess extends SavePostState {
  final bool isSaved;
  const SavePostSuccess({required this.isSaved});

  @override
  List<Object> get props => [isSaved];
}