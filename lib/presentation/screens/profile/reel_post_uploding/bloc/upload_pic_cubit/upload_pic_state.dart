part of 'upload_pic_cubit.dart';

@immutable
sealed class UploadPicState {}

final class UploadPicInitial extends UploadPicState {}

final class UploadLoadingState extends UploadPicState{}

final class UploadPicErrorState extends UploadPicState{
  final String error;
  UploadPicErrorState({required this.error});
}

final class UploadPicSuccessState extends UploadPicState{}
