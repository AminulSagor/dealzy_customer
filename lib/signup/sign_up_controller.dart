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

  // Geo args (optional)
  final RxnDouble latitude = RxnDouble();
  final RxnDouble longitude = RxnDouble();
  final RxString postalCode = ''.obs;      // e.g., 1229
  final RxString adminDistrict = ''.obs;   // e.g., Dhaka Division
  final RxString district = ''.obs;        // e.g., Dhaka District (for UI label only)
  final RxString city = ''.obs;            // e.g., Dhaka (for UI label only)
  final RxString street = ''.obs;          // optional (unused in payload)

  late final SignupService _signupService;

  // ---------- validators ----------
  String? validatePhone(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Phone is required';
    final digits = s.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Enter a valid phone number';
    return null;
  }

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

  // Location is optional — no validator for it
  void _revalidate() {
    // Validate only required fields
    isValid.value = (formKey.currentState?.validate() ?? false);
  }
  void revalidate() => _revalidate();

  void _updateLocationLabel() {
    // Prefer: District • Postal ; fallback: District • City
    final hasPostal = postalCode.value.isNotEmpty;
    final hasCity = city.value.isNotEmpty;
    final parts = <String>[
      if (district.value.isNotEmpty) district.value,
      if (hasPostal) postalCode.value else if (hasCity) city.value,
    ];
    locationDisplayCtrl.text = parts.isEmpty ? '' : parts.join(' • ');
    // Not needed for validity (location is optional), but keeps UI reactive:
    _revalidate();
  }

  bool get hasLocation => latitude.value != null && longitude.value != null;

  // ---------- submit ----------
  Future<void> submit() async {
    // Validate required fields only
    if (!(formKey.currentState?.validate() ?? false)) {
      _revalidate();
      return;
    }

    isBusy.value = true;
    try {
      final r = await _signupService.signUp(
        name: usernameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
        latitude: latitude.value,            // double? (nullable)
        longitude: longitude.value,          // double? (nullable)
        postCode: postalCode.value.isEmpty ? null : postalCode.value,
        adminDistrict: adminDistrict.value.isEmpty ? null : adminDistrict.value,
        // Note: district/city/street are NOT part of the service payload now
      );

      if (r.success) {
        Get.snackbar('Success', r.message.isNotEmpty ? r.message : 'User registered successfully');
        FocusManager.instance.primaryFocus?.unfocus();
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