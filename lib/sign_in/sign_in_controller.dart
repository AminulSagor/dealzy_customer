import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final phoneCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();

  final isBusy = false.obs;
  final isValid = false.obs;

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

  void _revalidate() {
    isValid.value = formKey.currentState?.validate() ?? false;
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      _revalidate();
      return;
    }
    isBusy.value = true;
    try {
      // TODO: call sign-in API
      await Future.delayed(const Duration(milliseconds: 700));
      Get.snackbar('Welcome back', 'Signed in successfully!');
      // TODO: navigate to home
      // Get.offAllNamed(AppPages.home);
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
