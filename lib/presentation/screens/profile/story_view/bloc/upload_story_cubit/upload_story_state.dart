part of 'upload_story_cubit.dart';


@immutable
sealed class UploadStoryState {}

final class UploadStoryInitial extends UploadStoryState {}

final class UploadStoryLoading extends UploadStoryState {}

final class UploadStoryError extends UploadStoryState {
  final String error;
  UploadStoryError({required this.error});
}

final class UploadStorySuccess extends UploadStoryState {}