import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'upload_pic_state.dart';

class UploadPicCubit extends Cubit<UploadPicState> {
  UploadPicCubit() : super(UploadPicInitial());

  uploadPic({required String picPath, required String caption})async{

  }
}
