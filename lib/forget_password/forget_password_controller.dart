// lib/controller/forget_password_controller.dart
import 'package:dealzy/forget_password/send_otp_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class ForgetPasswordController extends GetxController {
  ForgetPasswordController({SendOtpService? sendOtpService})
      : _sendOtpService = sendOtpService ?? SendOtpService();

  final emailController = TextEditingController();
  final isSubmitting = false.obs;

  final SendOtpService _sendOtpService;

  Future<void> submit() async {
    if (isSubmitting.value) return; // prevent double taps

    final email = emailController.text.trim();
    if (!GetUtils.isEmail(email)) {
      Get.snackbar("Invalid", "Please enter a valid email address");
      return;
    }

    isSubmitting.value = true;
    try {
      final result = await _sendOtpService.sendOtp(email);

      final status = (result['status'] ?? '').toString().toLowerCase();
      final message = (result['message'] ?? '').toString();

      if (status == 'success') {

        Get.toNamed(
          "/otp-verification",
          arguments: {"email": email},
        );
      } else {
        Get.snackbar("Error", message.isNotEmpty ? message : "Failed to send OTP");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
