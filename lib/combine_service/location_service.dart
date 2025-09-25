import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<String> getUserLocation() async {
    // Check service
    if (!await Geolocator.isLocationServiceEnabled()) {
      return "Location disabled";
    }

    // Check permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return "Permission denied";
    }
    if (permission == LocationPermission.deniedForever) {
      return "Permission denied forever";
    }

    // Get position
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Reverse geocoding
    final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      // place.subAdministrativeArea often contains **district**
      return place.subAdministrativeArea ?? place.locality ?? "Unknown location";
    }

    return "Unknown location";
  }
}
