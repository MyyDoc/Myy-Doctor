import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myydoctor/data/user/doctor_search_model.dart';
import 'package:myydoctor/services/location/doctors_location.dart';

part 'search_near_doctor_state.dart';

class SearchNearDoctorCubit extends Cubit<SearchNearDoctorState> {
  SearchNearDoctorCubit() : super(SearchNearDoctorInitial());

  Future searchResult (String searchQuery)async {
    try {
      emit(SearchingDoctorState());
      bool isLocationOn = await Geolocator.isLocationServiceEnabled();
      if(!isLocationOn){
        emit(SearchErrorState(message: 'Turn on your location'));
        return;
      }
      final result = await DoctorSearchService().searchDoctorsFromFirestore(userLat: null, userLng: null, searchQuery: searchQuery);

      emit(SearchDoctorSuccsussState(doctors: result));
    } catch (e) {
      emit(SearchErrorState(message: e.toString()));
    }
  }
}