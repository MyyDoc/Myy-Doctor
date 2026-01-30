import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myydoctor/data/user/doctor_search_model.dart';

class DoctorSearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 PUBLIC METHOD
  /// Fetches directly from Firestore
  Future<List<DoctorSearchModel>> searchDoctorsFromFirestore({
    double? userLat,
    double? userLng,
    required String searchQuery,
    double maxDistanceKm = 50,
  }) async {
    try {
      final snapshot = await _firestore.collection('users').get();

      // 🔹 Only take users whose preference contains "Doctor"
      final docs = snapshot.docs
          .where((doc) {
        final data = doc.data();
        final List preferences =
        List.from(data['userPreference'] ?? []);
        return preferences.contains("Doctor");
      })
          .map((doc) => {
        ...doc.data(),
        'id': doc.id,
      })
          .toList();

      return _searchFromRawDocs(
        userLat: userLat,
        userLng: userLng,
        searchQuery: searchQuery,
        rawDoctors: docs,
        maxDistanceKm: maxDistanceKm,
      );
    } catch (e) {
      return [];
    }
  }


  /// 🔹 EXISTING STYLE METHOD (STILL WORKS)
  List<DoctorSearchModel> searchDoctorsFromList({
    double? userLat,
    double? userLng,
    required String searchQuery,
    required List<Map<String, dynamic>> rawDoctors,
    double maxDistanceKm = 50,
  }) {
    return _searchFromRawDocs(
      userLat: userLat,
      userLng: userLng,
      searchQuery: searchQuery,
      rawDoctors: rawDoctors,
      maxDistanceKm: maxDistanceKm,
    );
  }

  /// 🔹 CORE LOGIC
  List<DoctorSearchModel> _searchFromRawDocs({
    double? userLat,
    double? userLng,
    required String searchQuery,
    required List<Map<String, dynamic>> rawDoctors,
    required double maxDistanceKm,
  }) {
    final List<DoctorSearchModel> results = [];
    final query = searchQuery.toLowerCase().trim();

    final bool hasUserLocation =
        userLat != null && userLng != null;

    for (final doc in rawDoctors) {
      try {
        // 🔸 Match name OR speciality always
        if (!_matchesQuery(doc, query)) continue;

        double distanceKm = 0;

        // 🔸 Distance logic ONLY if user location exists
        if (hasUserLocation && _hasValidLocation(doc)) {
          final double lat = (doc['lat'] as num).toDouble();
          final double lng = (doc['lng'] as num).toDouble();

          distanceKm = _calculateDistanceKm(
            userLat,
            userLng,
            lat,
            lng,
          );

          if (distanceKm > maxDistanceKm) continue;
        }

        results.add(
          DoctorSearchModel.fromFirestore(
            id: doc['id'].toString(),
            data: doc,
            distanceKm: distanceKm,
          ),
        );
      } catch (_) {
        continue;
      }
    }

    // 🔸 Sort ONLY if distance is meaningful
    if (hasUserLocation) {
      results.sort(
        (a, b) => a.distanceKm.compareTo(b.distanceKm),
      );
    }

    return results;
  }

  /// 🔹 NAME OR SPECIALITY MATCH
  bool _matchesQuery(
    Map<String, dynamic> data,
    String query,
  ) {
    if (query.isEmpty) return true;

    final name =
        (data['fullName'] ?? '').toString().toLowerCase();

    final specialities = List<String>.from(
      data['specialities'] ?? [],
    ).map((e) => e.toLowerCase());

    return name.contains(query) ||
        specialities.any((s) => s.contains(query));
  }

  bool _hasValidLocation(Map<String, dynamic> data) {
    return data['lat'] is num && data['lng'] is num;
  }

  /// 🔹 Haversine
  double _calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371;

    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);
}
