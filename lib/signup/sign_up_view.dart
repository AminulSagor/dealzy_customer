import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'sign_up_controller.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF3F5F7),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Controls for the overlap
    final double logoHeight = 180.h; // logo size
    final double overlap = 56.h;     // how much it overlaps onto the card

    return Scaffold(
      backgroundColor: const Color(0xFF124A89),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Stack: logo overlaps the card
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // Card pushed down so the logo sits on it
                    Padding(
                      padding: EdgeInsets.only(top: logoHeight - overlap),
                      child: Card(
                        elevation: 3,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                          child: Form(
                            key: controller.formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Title + subtitle
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text:
                                        'Get a smarter, smoother shopping experience.\n',
                                      ),
                                      TextSpan(
                                        text: 'Sign up now!',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF1C1C1C),
                                    height: 1.35,
                                  ),
                                ),
                                SizedBox(height: 16.h),

                                // Phone
                                TextFormField(
                                  controller: controller.phoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[\d\s+\-()]')),
                                    LengthLimitingTextInputFormatter(18),
                                  ],
                                  validator: controller.validatePhone,
                                  decoration: _dec('enter your phone number'),
                                ),
                                SizedBox(height: 12.h),

                                // Username
                                TextFormField(
                                  controller: controller.usernameCtrl,
                                  textInputAction: TextInputAction.next,
                                  validator: controller.validateUsername,
                                  decoration: _dec('username'),
                                ),
                                SizedBox(height: 12.h),

                                // Location dropdown
                                Obx(() {
                                  return DropdownButtonFormField<String>(
                                    value: controller.selectedLocation.value.isEmpty
                                        ? 'location'
                                        : controller.selectedLocation.value,
                                    items: controller.locations
                                        .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                        .toList(),
                                    onChanged: (v) {
                                      controller.selectedLocation.value = v ?? '';
                                      controller.formKey.currentState?.validate();
                                    },
                                    validator: controller.validateLocation,
                                    decoration: _dec('location'),
                                    icon: const Icon(Icons.expand_more_rounded),
                                  );
                                }),
                                SizedBox(height: 18.h),

                                // Confirm button
                                Obx(() {
                                  final busy = controller.isBusy.value;
                                  return SizedBox(
                                    width: 0.38.sw,
                                    height: 46.h,
                                    child: ElevatedButton(
                                      onPressed: busy ? null : controller.submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF124A89),
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor:
                                        const Color(0xFF124A89).withOpacity(0.45),
                                        disabledForegroundColor: Colors.white70,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14.r),
                                        ),
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      child:
                                      Text(busy ? 'Please wait…' : 'confirm'),
                                    ),
                                  );
                                }),

                                SizedBox(height: 16.h),

                                // Sign in text
                                // Sign in text (two lines, centered)
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'If you have an account, just',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF2E2E2E),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        // Get.toNamed(AppPages.signIn);
                                      },
                                      child: Text(
                                        'Sign in now!',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w700,

                                        ),
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

                    // Overlapping logo
                    Positioned(
                      top: 0,
                      child: Image.asset(
                        'assets/png/logo.png',
                        height: logoHeight,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Left illustration
                    Positioned(
                      left: -6.w,
                      bottom: -14.h,
                      child: Image.asset(
                        'assets/png/woman.png',
                        height: 150.h,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Right illustration
                    Positioned(
                      right: -6.w,
                      bottom: -14.h,
                      child: Image.asset(
                        'assets/png/man.png',
                        height: 150.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),

                // Extra space so bottom-overlapping art isn't clipped
                SizedBox(height: 60.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
