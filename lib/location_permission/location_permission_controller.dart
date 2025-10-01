import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../routes/app_routes.dart';

class LocationPermissionController extends GetxController {
  final isBusy = false.obs;

  Future<void> requestLocation() async {
    if (isBusy.value) return;
    isBusy.value = true;

    try {
      // --- Service check
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Location disabled', 'Please enable Location services.');
        return;
      }

      // --- Permission check
      LocationPermission permission = await Geolocator.checkPermission();


      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        Get.snackbar('Permission denied', 'Location is required to show nearby deals.');
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Permission permanently denied', 'Enable it from Settings.');
        await Geolocator.openAppSettings();
        return;
      }

      // --- Get position (with timeout and fallback)
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      } on TimeoutException catch (_) {

        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos == null) {
        Get.snackbar('Location error', 'Unable to get your current position.');
        return;
      }

      final double latitude = pos.latitude;
      final double longitude = pos.longitude;


      // --- Reverse geocoding (robust)
      final resolved = await _resolveAddress(latitude, longitude);



      // --- Build arguments for next screen
      final args = <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'postalCode': resolved.postal,            // now likely filled if available
        'adminDistrict': resolved.admin,          // e.g., Dhaka Division
        'district': resolved.district,            // e.g., Dhaka
        'city': resolved.locality,                // optional extra context
      };

      // --- Navigate
      Get.offAllNamed(AppRoutes.signUp, arguments: args);
    } catch (e, st) {
      Get.snackbar('Error', e.toString());
    } finally {
      isBusy.value = false;
    }
  }

  /// Tries to get a Placemark with a non-empty postal code.
  /// Falls back to first placemark if none have a postal code.
  Future<_ResolvedPlacemark> _resolveAddress(double lat, double lng) async {
    List<Placemark> marks = [];

    try {
      // 1) default lookup
      marks = await placemarkFromCoordinates(lat, lng);
      _debugList('default', marks);

      // 2) retry with Bangladesh locale if postal is missing
      if (_bestWithPostal(marks) == null) {
        final retry = await placemarkFromCoordinates(lat, lng, localeIdentifier: 'en_BD');
        if (retry.isNotEmpty) {
          marks = retry;
          _debugList('en_BD', marks);
        }
      }
    } catch (e) {
    }

    if (marks.isEmpty) {
      return const _ResolvedPlacemark();
    }

    final best = _bestWithPostal(marks) ?? marks.first;

    return _ResolvedPlacemark(
      postal: (best.postalCode ?? '').isNotEmpty ? best.postalCode : null,
      admin: best.administrativeArea,         // Division (BD)
      district: best.subAdministrativeArea,   // District (BD)
      locality: best.locality,
      subLocality: best.subLocality,
      country: best.country,
      iso: best.isoCountryCode,
      street: best.street,
    );
  }

  Placemark? _bestWithPostal(List<Placemark> list) {
    for (final p in list) {
      if ((p.postalCode ?? '').trim().isNotEmpty) return p;
    }
    return null;
  }

  void _debugList(String tag, List<Placemark> list) {
    if (list.isEmpty) {
      return;
    }
    for (var i = 0; i < list.length; i++) {
      final p = list[i];

    }
  }
}

class _ResolvedPlacemark {
  final String? postal;
  final String? admin;
  final String? district;
  final String? locality;
  final String? subLocality;
  final String? country;
  final String? iso;
  final String? street;

  const _ResolvedPlacemark({
    this.postal,
    this.admin,
    this.district,
    this.locality,
    this.subLocality,
    this.country,
    this.iso,
    this.street,
  });
}
