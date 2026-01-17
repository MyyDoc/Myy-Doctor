class DoctorSearchModel {
  final String id;
  final String name;
  final String profilePictureUrl;
  final List<String> specialities;
  final double distanceKm;

  DoctorSearchModel({
    required this.id,
    required this.name,
    required this.profilePictureUrl,
    required this.specialities,
    required this.distanceKm,
  });

  factory DoctorSearchModel.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
    required double distanceKm,
  }) {
    return DoctorSearchModel(
      id: id,
      name: (data['fullName'] ?? '').toString(),
      profilePictureUrl:
          (data['profilePicture'] ?? '').toString(),
      specialities:
          List<String>.from(data['specialities'] ?? []),
      distanceKm: distanceKm,
    );
  }
}
