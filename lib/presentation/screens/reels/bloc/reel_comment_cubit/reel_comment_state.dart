part of 'reel_comment_cubit.dart';

abstract class ReelCommentState {}

class ReelCommentInitial extends ReelCommentState {}

class CommentLoading extends ReelCommentState {}

class CommentLoaded extends ReelCommentState {
  final List<ReelComment> comments;
  CommentLoaded(this.comments);
}

class CommentError extends ReelCommentState {
  final String message;
  CommentError(this.message);
}
