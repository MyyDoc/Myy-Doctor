part of 'fetch_my_stories_cubit.dart';

@immutable
sealed class FetchMyStoriesState extends Equatable {
  const FetchMyStoriesState();

  @override
  List<Object> get props => [];
}

final class FetchMyStoriesInitial extends FetchMyStoriesState {}

final class FetchMyStoriesLoading extends FetchMyStoriesState {}

final class FetchMyStoriesError extends FetchMyStoriesState {
  final String message;
  const FetchMyStoriesError(this.message);

  @override
  List<Object> get props => [message];
}

final class FetchMyStoriesSuccess extends FetchMyStoriesState {
  final List<StoryModel> stories;
  const FetchMyStoriesSuccess({required this.stories});

  @override
  List<Object> get props => [stories];
}
