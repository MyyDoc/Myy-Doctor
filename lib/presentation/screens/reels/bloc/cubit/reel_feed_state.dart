part of 'reel_feed_cubit.dart';

abstract class ReelFeedState {}

class ReelFeedInitial extends ReelFeedState {}

class ReelFeedLoading extends ReelFeedState {}

class ReelFeedLoaded extends ReelFeedState {
  final List<ReelItems> reels;
  ReelFeedLoaded(this.reels);
}

class ReelFeedError extends ReelFeedState {
  final String error;
  ReelFeedError(this.error);
}
