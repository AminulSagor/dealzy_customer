import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../routes/app_routes.dart';
import 'signup_service.dart';

class SignUpController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final phoneCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final locationDisplayCtrl = TextEditingController(); // read-only UI label
  final emailCtrl = TextEditingController();

  // UI/state
  final RxBool showPassword = false.obs;
  final RxBool isBusy = false.obs;
  final RxBool isValid = false.obs;
  final RxBool agreed = false.obs;

  // Geo args
  final RxnDouble latitude = RxnDouble();
  final RxnDouble longitude = RxnDouble();
  final RxString postalCode = ''.obs;      // e.g., 1229
  final RxString adminDistrict = ''.obs;   // e.g., Dhaka Division
  final RxString district = ''.obs;        // e.g., Dhaka District
  final RxString city = ''.obs;            // e.g., Dhaka
  final RxString street = ''.obs;          // optional

  late final SignupService _signupService;

  // ---------- validators ----------
  String? validatePhone(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Phone is required';
    final digits = s.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Enter a valid phone number';
    return null;
  }

  // Add controller


// ---------- validators ----------
  String? validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(s)) return 'Enter a valid email';
    return null;
  }


  String? validateUsername(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Username is required';
    if (s.length < 3) return 'At least 3 characters';
    return null;
  }

  String? validatePassword(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Password is required';
    if (s.length < 6) return 'At least 6 characters';
    return null;
  }

  String? validateLocationDisplay(String? _) =>
      locationDisplayCtrl.text.trim().isEmpty ? 'Location not available' : null;

  void _revalidate() {
    isValid.value = (formKey.currentState?.validate() ?? false);
  }
  // SignUpController
  void revalidate() => _revalidate();


  void _updateLocationLabel() {
    // Prefer: District • Postal ; fallback: District • City
    final hasPostal = postalCode.value.isNotEmpty;
    final hasCity = city.value.isNotEmpty;
    final parts = <String>[
      if (district.value.isNotEmpty) district.value,
      if (hasPostal) postalCode.value else if (hasCity) city.value,
    ];
    locationDisplayCtrl.text = parts.join(' • ');
    _revalidate();
  }

  // ---------- submit ----------
  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      _revalidate();
      return;
    }
    if (latitude.value == null || longitude.value == null) {
      Get.snackbar('Location missing', 'Please allow location to continue.');
      return;
    }

    isBusy.value = true;
    try {
      final r = await _signupService.signUp(
        name: usernameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
        latitude: latitude.value!,
        longitude: longitude.value!,
        postCode: postalCode.value.isEmpty ? null : postalCode.value,
        adminDistrict: district.value.isEmpty ? null : district.value,
      );

      if (r.success) {
        Get.snackbar('Success', r.message.isNotEmpty ? r.message : 'User registered successfully');

        // ✅ Unfocus BEFORE route change to let EditableText detach cleanly
        FocusManager.instance.primaryFocus?.unfocus();
        // Give the framework a microtask/frame to process the focus change
        await Future<void>.delayed(const Duration(milliseconds: 1));

        Get.offAllNamed(AppRoutes.signIn);
      } else {
        Get.snackbar('Signup failed', r.message.isNotEmpty ? r.message : r.status);
      }
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
    _signupService = SignupService(); // reads .env internally

    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      latitude.value      = (args['latitude'] as num?)?.toDouble();
      longitude.value     = (args['longitude'] as num?)?.toDouble();
      postalCode.value    = (args['postalCode'] as String?) ?? '';
      adminDistrict.value = (args['adminDistrict'] as String?) ?? '';
      district.value      = (args['district'] as String?) ?? '';
      city.value          = (args['city'] as String?) ?? '';
      street.value        = (args['street'] as String?) ?? '';
    }

    _updateLocationLabel();

    phoneCtrl.addListener(_revalidate);
    usernameCtrl.addListener(_revalidate);
    passwordCtrl.addListener(_revalidate);
    emailCtrl.addListener(_revalidate);


    everAll([district, postalCode, city], (_) => _updateLocationLabel());
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    locationDisplayCtrl.dispose();
    emailCtrl.dispose();

    super.onClose();
  }
}
