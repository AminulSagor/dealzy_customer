import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../storage/token_storage.dart';
import 'delete_user_service.dart';
import 'logout_service.dart';
import 'profile_service.dart';

class AppSettingController extends GetxController {
  AppSettingController({
    LogoutService? logoutService,
    ProfileService? profileService,
  })  : _logoutService = logoutService ?? LogoutService(),
        _profileService = profileService ?? ProfileService();

  final LogoutService _logoutService;
  final ProfileService _profileService;

  // Profile state
  final profileName = ''.obs;
  final profilePhone = ''.obs;
  final profileImageUrl = ''.obs;

  final isLoadingProfile = false.obs;
  final profileError = RxnString();

  // Logout state
  final isLoggingOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  // ------- Profile -------
  Future<void> _loadProfile() async {
    isLoadingProfile.value = true;
    profileError.value = null;
    try {
      final p = await _profileService.getProfile();
      profileName.value = p.name;
      profilePhone.value = p.phone;
      profileImageUrl.value = (p.imagePath).trim();
    } catch (e) {
      profileError.value = e.toString();
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> reloadProfile() => _loadProfile();

  // ------- Delete (after confirm in view) -------
  Future<void> deleteProfileConfirmed(BuildContext context) async {
    try {
      final result = await DeleteUserService.deleteUser();

      if (result['status'] == 'success') {
        // Clear token after deletion
        await TokenStorage.clearToken();

        // Navigate home
        Get.offAllNamed(AppRoutes.home);

        // Success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account has been deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Failure message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete account.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ------- Logout (after confirm in view) -------
  Future<void> performLogout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;
    try {
      await _logoutService.logout();
      await TokenStorage.clearToken();
      Get.offAllNamed(AppRoutes.home);

    } catch (e) {
      // Even if server call fails, clear local session
      await TokenStorage.clearToken();
      Get.offAllNamed(AppRoutes.home);
      Get.snackbar(
        'Signed Out',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoggingOut.value = false;
    }
  }


}
