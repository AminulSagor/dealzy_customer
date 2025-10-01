import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../routes/app_routes.dart';
import '../storage/token_storage.dart';
import 'login_service.dart';

class SignInController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final isBusy = false.obs;
  final isValid = false.obs;
  final showPassword = false.obs;

  late final LoginService _loginService;

  // ---------- validators ----------
  String? validatePhone(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Phone is required';
    final digits = s.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Enter a valid phone number';
    return null;
  }

  String? validatePassword(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Password is required';
    if (s.length < 4) return 'At least 4 characters';
    return null;
  }

  void _revalidate() => isValid.value = formKey.currentState?.validate() ?? false;

  // ---------- submit ----------
  Future<void> submit() async {
    if (isBusy.value) return;

    final isFormValid = formKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      _revalidate();
      return;
    }

    isBusy.value = true;
    try {
      final normalizedPhone = phoneCtrl.text.replaceAll(RegExp(r'\D'), '');

      final r = await _loginService.login(
        phone: normalizedPhone,
        password: passwordCtrl.text.trim(),
      );

      if (!r.success) {
        Get.snackbar('Login failed', r.message.isNotEmpty ? r.message : r.status);
        return;
      }

      final u     = r.user;
      final token = (u?['token'] ?? '').toString().trim();
      if (token.isEmpty) {
        Get.snackbar('Login', 'Missing token in response.');
        return;
      }

      // 1) Save token only
      await TokenStorage.saveToken(token);

      // 2) Go home
      Get.offAllNamed(AppRoutes.home);
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Network error';
      Get.snackbar('Network error', msg);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isBusy.value = false;
    }
  }




  // ---------- lifecycle ----------
  @override
  void onInit() {
    super.onInit();
    _loginService = LoginService();

    phoneCtrl.addListener(_revalidate);
    passwordCtrl.addListener(_revalidate);
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
