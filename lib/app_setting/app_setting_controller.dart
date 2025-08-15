import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSettingController extends GetxController {
  final country = 'Bangladesh'.obs;
  final language = 'English'.obs;

  // You can load these from a service later
  final countries = const ['Bangladesh', 'United States', 'India', 'United Kingdom'];
  final languages = const ['English', 'বাংলা', 'Español', 'Français'];

  void openAccountSettings() {
    // TODO: navigate to your account/profile settings screen
    // Get.toNamed('/profile-setting');
    Get.snackbar('Account Settings', 'Open account settings page');
  }

  Future<void> pickCountry() async {
    final selected = await _pickFromList(
      title: 'Select Country',
      values: countries,
      current: country.value,
    );
    if (selected != null) country.value = selected;
  }

  Future<void> pickLanguage() async {
    final selected = await _pickFromList(
      title: 'Select Language',
      values: languages,
      current: language.value,
    );
    if (selected != null) language.value = selected;
  }

  void needHelp() {
    // TODO: route to support/FAQ
    Get.snackbar('Help', 'Open help & support');
  }

  Future<void> logout() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Log Out')),
        ],
      ),
      barrierDismissible: false,
    );
    if (ok == true) {
      // TODO: perform sign-out, clear tokens, etc.
      Get.snackbar('Logged Out', 'You have been signed out.');
      // Get.offAllNamed('/sign-in');
    }
  }

  /// Bottom sheet single-choice picker
  Future<String?> _pickFromList({
    required String title,
    required List<String> values,
    required String current,
  }) async {
    String temp = current;
    return Get.bottomSheet<String>(
      SafeArea(
        top: false,
        child: Material(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12, borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: values.length,
                    itemBuilder: (_, i) {
                      final v = values[i];
                      return RadioListTile<String>(
                        value: v,
                        groupValue: temp,
                        onChanged: (val) { temp = val!; Get.back(result: temp); },
                        title: Text(v),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
