import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:myydoctor/data/user/doctor_search_model.dart';
import 'package:myydoctor/services/search_near_doctor/near_doctor_search_result.dart';


class SearchNearDoctor {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<NearDoctorSearchResult<List<DoctorSearchModel>>> search({
    required String specialistId,
    double radiusKm = 10,
  }) async {
    try {
      // 🔍 Validate input
      if (specialistId.trim().isEmpty) {
        return NearDoctorSearchResult.failure(
          'Please enter a specialist to search',
        );
      }

      // 📍 Check location permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return NearDoctorSearchResult.failure(
          'Location permission is required to find nearby doctors',
        );
      }

      // 1️⃣ Get user location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 2️⃣ Bounding box
      final latDelta = radiusKm / 111;
      final lngDelta =
          radiusKm / (111 * cos(position.latitude * pi / 180));

      final minLat = position.latitude - latDelta;
      final maxLat = position.latitude + latDelta;
      final minLng = position.longitude - lngDelta;
      final maxLng = position.longitude + lngDelta;

      // 3️⃣ Firestore query
      final snapshot = await _firestore
          .collection('doctors')
          .where('specialistId', isEqualTo: specialistId)
          .where('isActive', isEqualTo: true)
          .where('lat', isGreaterThanOrEqualTo: minLat)
          .where('lat', isLessThanOrEqualTo: maxLat)
          .get();

      if (snapshot.docs.isEmpty) {
        return NearDoctorSearchResult.failure(
          'No nearby doctors found for this speciality',
        );
      }

      // 4️⃣ Filter + distance calc
      final List<DoctorSearchModel> results = [];

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final lat = data['lat'];
          final lng = data['lng'];

          if (lat == null || lng == null) continue;
          if (lng < minLng || lng > maxLng) continue;

          final distanceKm = Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                lat,
                lng,
              ) /
              1000;

          results.add(
            DoctorSearchModel.fromFirestore(
              id: doc.id,
              data: data,
              distanceKm: distanceKm,
            ),
          );
        } catch (e) {
          // Skip broken document but log it
          if (kDebugMode) {
            debugPrint(
              'Doctor doc parsing failed (${doc.id}): $e',
            );
          }
        }
      }

      if (results.isEmpty) {
        return NearDoctorSearchResult.failure(
          'No doctors available in your area',
        );
      }

      // 5️⃣ Sort
      results.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      return NearDoctorSearchResult.success(results);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('Firestore error: ${e.message}');
      }
      return NearDoctorSearchResult.failure(
        'Something went wrong while fetching doctors',
      );
    } on LocationServiceDisabledException {
      return NearDoctorSearchResult.failure(
        'Please enable location services to continue',
      );
    } catch (e, stack) {
      // 🔥 Catch-all (important)
      if (kDebugMode) {
        debugPrint('SearchNearDoctor error: $e');
        debugPrintStack(stackTrace: stack);
      }
      return NearDoctorSearchResult.failure(
        'Unexpected error occurred. Please try again.',
      );
    }
  }
}
 