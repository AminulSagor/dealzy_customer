import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSettingController extends GetxController {
  // Reactive profile fields (seed with example data)
  final name = 'Fouzia Hussain'.obs;
  final phone = '+880156854565'.obs;
  final email = 'hfouzia27@gmail.com'.obs;
  final location = 'Location'.obs; // fill with real value when available

  final isSaving = false.obs;

  // Generic editor for simple text fields (name/phone/email)
  Future<void> editField({
    required String title,
    required RxString target,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? hint,
  }) async {
    final ctrl = TextEditingController(text: target.value);
    final formKey = GlobalKey<FormState>();

    await Get.bottomSheet(
      SafeArea(
        top: false,
        child: Material(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: ctrl,
                    keyboardType: keyboardType,
                    decoration: InputDecoration(
                      hintText: hint ?? title,
                      border: const OutlineInputBorder(),
                    ),
                    validator: validator,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState?.validate() ?? false) {
                              target.value = ctrl.text.trim();
                              Get.back();
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    ctrl.dispose();
  }

  Future<void> setPassword() async {
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await Get.bottomSheet(
      SafeArea(
        top: false,
        child: Material(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text('Set Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.length < 6) return 'At least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v != newCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!(formKey.currentState?.validate() ?? false)) return;
                            isSaving.value = true;
                            try {
                              // TODO: call API to set password
                              await Future.delayed(const Duration(milliseconds: 500));
                              Get.back();
                              Get.snackbar('Password updated', 'Your password has been set.');
                            } finally {
                              isSaving.value = false;
                            }
                          },
                          child: Obx(() =>
                          isSaving.value ? const Text('Saving…') : const Text('Save')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    newCtrl.dispose();
    confirmCtrl.dispose();
  }

  // Example validators you can reuse
  String? validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
    if (!ok) return 'Enter a valid email';
    return null;
  }

  String? validatePhone(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Enter a valid phone number';
    return null;
  }
}
