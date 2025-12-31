import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myydoctor/data/user/user_model.dart';
import 'package:myydoctor/domain/profile/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc(this._profileRepository) : super(ProfileLoading()) {
    on<LoadProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final user = await _profileRepository.getUser();
        if (user == null) {
          emit(ProfileError("User not found"));
        } else {
          emit(ProfileLoaded(user));
        }
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    // Stream updates
    on<ProfileUpdates>((event, emit) {
      _profileRepository.userStream().listen((user) {
        if (user != null) {
          emit(ProfileLoaded(user));
        }
      });
    });
  }
}
