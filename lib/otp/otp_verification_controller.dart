import 'package:dealzy/otp/verify_otp_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


import '../routes/app_routes.dart';


class OtpVerificationController extends GetxController {
  OtpVerificationController() : otpLength = 6;

  final int otpLength;

  late final List<TextEditingController> ctrls;
  late final List<FocusNode> nodes;

  final isSubmitting = false.obs;
  final canSubmit = false.obs;

  // UI / args
  late final String destination;
  late final bool isEmail;

  final _verifyOtpService = VerifyOtpService();

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    destination = (args['email'] as String?) ?? '';
    isEmail = (args['isEmail'] as bool?) ?? true; // default true for email

    ctrls = List.generate(otpLength, (_) => TextEditingController());
    nodes = List.generate(otpLength, (_) => FocusNode());

    for (final c in ctrls) {
      c.addListener(_recompute);
    }
  }

  @override
  void onClose() {
    FocusManager.instance.primaryFocus?.unfocus();
    for (final n in nodes) n.dispose();
    for (final c in ctrls) c.dispose();
    super.onClose();
  }

  String get otp => ctrls.map((c) => c.text.trim()).join();

  void _recompute() {
    if (otp.length != otpLength) {
      canSubmit.value = false;
      return;
    }
    for (final c in ctrls) {
      if (c.text.length != 1) {
        canSubmit.value = false;
        return;
      }
    }
    canSubmit.value = true;
  }

  void _requestFocusAndShow(FocusNode node) {
    node.requestFocus();
    Future.microtask(() {
      SystemChannels.textInput.invokeMethod('TextInput.show');
    });
  }

  void onDigitChanged(int index, String value) {
    if (value.length > 1) {
      final pasted = value.replaceAll(RegExp(r'\D'), '');
      _fillFrom(index, pasted);
      return;
    }
    if (value.isNotEmpty && index < otpLength - 1) {
      _requestFocusAndShow(nodes[index + 1]);
    } else if (value.isNotEmpty && index == otpLength - 1) {
      Future.microtask(() {
        SystemChannels.textInput.invokeMethod('TextInput.show');
      });
    }
    _recompute();
  }

  KeyEventResult onDigitKey(FocusNode node, RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (ctrls[index].text.isEmpty && index > 0) {
        _requestFocusAndShow(nodes[index - 1]);
        ctrls[index - 1].selection = TextSelection.fromPosition(
          TextPosition(offset: ctrls[index - 1].text.length),
        );
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _fillFrom(int startIndex, String digits) {
    final chars = digits.split('');
    var i = startIndex;
    for (final ch in chars) {
      if (i >= otpLength) break;
      if (RegExp(r'\d').hasMatch(ch)) {
        ctrls[i].text = ch;
        i++;
      }
    }
    final nextIndex = (i <= otpLength - 1) ? i : otpLength - 1;
    _requestFocusAndShow(nodes[nextIndex]);
    _recompute();
  }

  // --- Submit ---
  Future<void> submit() async {
    if (!canSubmit.value || isSubmitting.value) return;
    isSubmitting.value = true;

    try {
      final result = await _verifyOtpService.verifyOtp(
        email: destination,
        otp: otp,
      );

      final status = (result['status'] ?? '').toString().toLowerCase();
      final message = (result['message'] ?? '').toString();

      if (status == 'success') {
        Get.offNamed(
          AppRoutes.updatePassword,
          arguments: {
            "email": destination,
            "otp": otp,                 // ✅ pass OTP forward
          },
        );

      } else {
        Get.snackbar("Error", message.isNotEmpty ? message : "Invalid OTP");
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void onHelp() {
    Get.snackbar(
      'Help',
      'Please contact support if you didn\'t get the code.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
