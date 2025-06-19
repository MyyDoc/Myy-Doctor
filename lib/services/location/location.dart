import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Check if location services are enabled and permissions are granted
  static Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  // Get current position and return city name
  static Future<String?> getCurrentCity() async {
    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return place.locality ?? place.subAdministrativeArea ?? place.administrativeArea;
      }
    } catch (e) {
      print('Error getting location: $e');
    }
    return null;
  }

  // Get full address details
  static Future<Map<String, String?>> getCurrentLocationDetails() async {
    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        return {};
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return {
          'city': place.locality,
          'district': place.subAdministrativeArea,
          'state': place.administrativeArea,
          'country': place.country,
          'pincode': place.postalCode,
          'street': place.street,
          'subLocality': place.subLocality,
        };
      }
    } catch (e) {
      print('Error getting location details: $e');
    }
    return {};
  }
}

// Widget to display current location
class CurrentLocationWidget extends StatefulWidget {
  final Function(String?)? onLocationReceived;

  const CurrentLocationWidget({Key? key, this.onLocationReceived}) : super(key: key);

  @override
  State<CurrentLocationWidget> createState() => _CurrentLocationWidgetState();
}

class _CurrentLocationWidgetState extends State<CurrentLocationWidget> {
  String? currentCity;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      String? city = await LocationService.getCurrentCity();
      setState(() {
        currentCity = city;
        isLoading = false;
      });

      if (widget.onLocationReceived != null) {
        widget.onLocationReceived!(city);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to get location';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Current Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Getting your location...'),
                ],
              )
            else if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              )
            else if (currentCity != null)
              Text(
                currentCity!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              )
            else
              const Text('Location not available'),
          ],
        ),
      ),
    );
  }
}
