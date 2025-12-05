import 'package:myydoctor/services/doctors_list.dart';

class DoctorSearchService {
  final DoctorsList doctorsList = DoctorsList();

  /// Filters doctors based on current location and search query
  /// Priority: Current location first, then search criteria
  List<Map<String, String>> searchDoctorsByLocation({
    required String? currentLocation,
    String? searchQuery,
    String? specialization,
  }) {
    // If no current location, return empty list
    if (currentLocation == null || currentLocation.isEmpty) {
      return [];
    }

    // First filter by current location
    List<Map<String, String>> locationBasedDoctors = doctorsList.docList
        .where((doctor) => doctor['location']!.toLowerCase() == currentLocation.toLowerCase())
        .toList();

    // If no search criteria, return all doctors in current location
    if ((searchQuery == null || searchQuery.isEmpty) && 
        (specialization == null || specialization.isEmpty)) {
      return locationBasedDoctors;
    }

    // Apply search filters on location-based results
    return locationBasedDoctors.where((doctor) {
      bool matchesSpecialization = specialization == null || 
          specialization.isEmpty ||
          doctor['specializedIn']!.toLowerCase().contains(specialization.toLowerCase());
      
      bool matchesSearch = searchQuery == null || 
          searchQuery.isEmpty ||
          doctor['name']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
          doctor['specializedIn']!.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesSpecialization && matchesSearch;
    }).toList();
  }

  /// Get doctors count for current location
  int getDoctorsCountForLocation(String? currentLocation) {
    if (currentLocation == null || currentLocation.isEmpty) {
      return 0;
    }
    
    return doctorsList.docList
        .where((doctor) => doctor['location']!.toLowerCase() == currentLocation.toLowerCase())
        .length;
  }

  /// Get available specializations in current location
  List<String> getSpecializationsForLocation(String? currentLocation) {
    if (currentLocation == null || currentLocation.isEmpty) {
      return [];
    }

    Set<String> specializations = {};
    
    doctorsList.docList
        .where((doctor) => doctor['location']!.toLowerCase() == currentLocation.toLowerCase())
        .forEach((doctor) {
          specializations.add(doctor['specializedIn']!);
        });

    return specializations.toList()..sort();
  }
}