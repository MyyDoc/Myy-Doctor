import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

part 'save_profile_preference_state.dart';

class SaveProfilePreferenceCubit extends Cubit<SaveProfilePreferenceState> {
  SaveProfilePreferenceCubit() : super(SaveProfilePreferenceInitial());
  static XFile? profileImage;
  static int? age;
  static String? occupation;
  static String? fieldOfWork;
  static String? doctorRegistrationNumber;

}
