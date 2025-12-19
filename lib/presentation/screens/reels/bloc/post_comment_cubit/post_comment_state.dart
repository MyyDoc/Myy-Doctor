part of 'post_comment_cubit.dart';

abstract class PostCommentState {}

class PostCommentInitial extends PostCommentState {}

class PostCommentLoaded extends PostCommentState {
  final List<ReelComment> comments;

  PostCommentLoaded(this.comments);
}

class PostCommentError extends PostCommentState {
  final String message;

  PostCommentError(this.message);
}
