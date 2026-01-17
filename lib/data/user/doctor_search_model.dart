class DoctorSearchModel {
  final String id;
  final String name;
  final String specialistId;
  final double lat;
  final double lng;
  final double distanceKm;

  DoctorSearchModel({
    required this.id,
    required this.name,
    required this.specialistId,
    required this.lat,
    required this.lng,
    required this.distanceKm,
  });

  factory DoctorSearchModel.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
    required double distanceKm,
  }) {
    return DoctorSearchModel(
      id: id,
      name: data['name'],
      specialistId: data['specialistId'],
      lat: data['lat'],
      lng: data['lng'],
      distanceKm: distanceKm,
    );
  }
}
