part of 'upload_reel_cubit.dart';

@immutable
abstract class UploadReelState {}

class UploadReelInitial extends UploadReelState {}

class UploadReelLoadingState extends UploadReelState {}

class UploadReelSuccessState extends UploadReelState {}

class UploadReelErrorState extends UploadReelState {
  final String error;
  UploadReelErrorState({required this.error});
}

class UploadingReelProgressState extends UploadReelState {
 final double progress;
  UploadingReelProgressState({required this.progress});
}