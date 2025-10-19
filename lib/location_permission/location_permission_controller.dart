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
        Get.snackbar('Location services are off', 'No problem, It is optional.');
        _goNext();
        return;
      }

      // --- Permission check
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        Get.snackbar('Permission denied', 'No problem, It is optional.');
        _goNext();
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Permission permanently denied', 'No problem, It is optional.');
        _goNext();
        return;
      }

      // --- Get position (with timeout and fallback)
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      } on TimeoutException {
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos == null) {
        Get.snackbar('Couldn’t get location', 'Proceeding without location.');
        _goNext();
        return;
      }

      final latitude = pos.latitude;
      final longitude = pos.longitude;

      // --- Reverse geocoding (best-effort)
      final resolved = await _resolveAddress(latitude, longitude);

      // --- Navigate with args
      _goNext({
        'latitude': latitude,
        'longitude': longitude,
        'postalCode': resolved.postal,
        'adminDistrict': resolved.admin,
        'district': resolved.district,
        'city': resolved.locality,
      });
    } catch (e) {
      Get.snackbar('Location error', 'Proceeding without location. (${e.runtimeType})');
      _goNext();
    } finally {
      isBusy.value = false;
    }
  }

  /// User pressed "Next / Continue without location"
  void continueWithoutLocation() {
    _goNext({
      'latitude': null,
      'longitude': null,
      'manual': false, // optional flag for downstream logic
    });
  }

  /// Centralized navigation for both flows
  void _goNext([Map<String, dynamic>? args]) {
    Get.toNamed(AppRoutes.signUp, arguments: args);
  }

  /// Tries to get a Placemark with postalCode; falls back to first.
  Future<_ResolvedPlacemark> _resolveAddress(double lat, double lng) async {
    List<Placemark> marks = [];

    try {
      marks = await placemarkFromCoordinates(lat, lng);
      if (_bestWithPostal(marks) == null) {
        final retry = await placemarkFromCoordinates(lat, lng, localeIdentifier: 'en_BD');
        if (retry.isNotEmpty) {
          marks = retry;
        }
      }
    } catch (_) {
      // ignore geocoding failures
    }

    if (marks.isEmpty) return const _ResolvedPlacemark();
    final best = _bestWithPostal(marks) ?? marks.first;

    return _ResolvedPlacemark(
      postal: (best.postalCode ?? '').isNotEmpty ? best.postalCode : null,
      admin: best.administrativeArea,
      district: best.subAdministrativeArea,
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