import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../routes/app_pages.dart';

class LocationPermissionController extends GetxController {
  final isBusy = false.obs;

  Future<void> requestLocation() async {
    if (isBusy.value) return;
    isBusy.value = true;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Location disabled', 'Please enable Location services.');
        isBusy.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        Get.snackbar('Permission denied', 'Location is required to show nearby deals.');
        isBusy.value = false;
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Permission permanently denied', 'Enable it from Settings.');
        await Geolocator.openAppSettings();
        isBusy.value = false;
        return;
      }

      // Granted
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      //Get.offAllNamed(AppPages.onboarding); // TODO: change to your next route
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isBusy.value = false;
    }
  }
}
