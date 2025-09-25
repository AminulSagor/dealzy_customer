import 'package:dealzy/update_password/update_password_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../routes/app_routes.dart';


class UpdatePasswordController extends GetxController {
  final newPwdCtrl = TextEditingController();
  final confirmPwdCtrl = TextEditingController();

  final newPwdNode = FocusNode();
  final confirmPwdNode = FocusNode();

  final isSubmitting = false.obs;
  final canSubmit = false.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  // error messages for TextFields
  final newPwdError = RxnString();
  final confirmPwdError = RxnString();

  // From previous screen (OTP verify)
  late final String email;
  late final String otp;

  final _service = UpdatePasswordService();

  @override
  void onInit() {
    super.onInit();

    // Expecting: Get.toNamed(AppRoutes.updatePassword, arguments: {"email": "...", "otp": "...."});
    final args = (Get.arguments is Map) ? Get.arguments as Map : const {};
    email = (args['email'] ?? '').toString();
    otp   = (args['otp'] ?? '').toString();

    newPwdCtrl.addListener(_recompute);
    confirmPwdCtrl.addListener(_recompute);
  }

  @override
  void onClose() {
    newPwdCtrl.dispose();
    confirmPwdCtrl.dispose();
    newPwdNode.dispose();
    confirmPwdNode.dispose();
    super.onClose();
  }

  // ── Validation ──────────────────────────────────────────────────────────────
  static final _upper  = RegExp(r'[A-Z]');
  static final _digit  = RegExp(r'\d');
  static final _symbol = RegExp(r'[^\w\s]'); // non-letter/number/underscore/space

  bool _isStrong(String s) =>
      s.length >= 8 && _upper.hasMatch(s) && _digit.hasMatch(s) && _symbol.hasMatch(s);

  String? _strengthError(String s) {
    if (s.isEmpty) return null;
    if (s.length < 8) return 'At least 8 characters required';
    if (!_upper.hasMatch(s)) return 'Include at least one UPPERCASE letter';
    if (!_digit.hasMatch(s)) return 'Include at least one number';
    if (!_symbol.hasMatch(s)) return 'Include at least one symbol';
    return null;
  }

  void _recompute() {
    final a = newPwdCtrl.text;
    final b = confirmPwdCtrl.text;

    newPwdError.value = _strengthError(a);

    if (b.isEmpty) {
      confirmPwdError.value = null;
    } else if (a != b) {
      confirmPwdError.value = 'Passwords do not match';
    } else {
      confirmPwdError.value = null;
    }

    canSubmit.value = _isStrong(a) && a == b;
  }

  // ── Action ─────────────────────────────────────────────────────────────────
  Future<void> submit() async {
    if (!canSubmit.value || isSubmitting.value) return;

    if (email.isEmpty || otp.isEmpty) {
      Get.snackbar('Error', 'Missing email or OTP. Please restart the reset flow.');
      return;
    }

    isSubmitting.value = true;
    try {
      final result = await _service.updatePassword(
        email: email,
        password: newPwdCtrl.text,
        otp: otp, // header
      );

      final status = (result['status'] ?? '').toString().toLowerCase();
      final message = (result['message'] ?? '').toString();

      if (status == 'success') {
        Get.snackbar('Success', message.isNotEmpty ? message : 'Password changed successfully');
        Get.offAllNamed(AppRoutes.signIn);
      } else {
        Get.snackbar('Error', message.isNotEmpty ? message : 'Failed to change password');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSubmitting.value = false;
    }
  }
}
