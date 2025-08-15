import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final phoneCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();

  final RxString selectedLocation = ''.obs;
  final RxBool isBusy = false.obs;
  final RxBool isValid = false.obs;

  // TODO: replace with your real locations or fetch dynamically
  final List<String> locations = const [
    'location',
    'New York',
    'San Francisco',
    'Chicago',
    'Los Angeles',
  ];

  String? validatePhone(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Phone is required';
    final digits = s.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Enter a valid phone number';
    return null;
  }

  String? validateUsername(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Username is required';
    if (s.length < 3) return 'At least 3 characters';
    return null;
  }

  String? validateLocation(String? v) {
    if ((v ?? '').isEmpty || v == 'location') return 'Please select a location';
    return null;
  }

  void _revalidate() {
    final ok = (formKey.currentState?.validate() ?? false);
    isValid.value = ok;
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      _revalidate();
      return;
    }
    isBusy.value = true;
    try {
      // TODO: call API / next step
      await Future.delayed(const Duration(milliseconds: 600));
      Get.snackbar('Success', 'Account created!');
      // Get.offAllNamed(AppPages.home); // navigate where you want
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isBusy.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    phoneCtrl.addListener(_revalidate);
    usernameCtrl.addListener(_revalidate);
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    usernameCtrl.dispose();
    super.onClose();
  }
}
