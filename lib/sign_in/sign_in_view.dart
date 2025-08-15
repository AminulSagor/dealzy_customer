import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'sign_in_controller.dart';
import '../routes/app_pages.dart';

class SignInView extends GetView<SignInController> {
  const SignInView({super.key});

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

    // Overlap controls (logo over card)
    final double logoHeight = 180.h;
    final double overlap = 58.h;

    return Scaffold(
      backgroundColor: const Color(0xFF124A89),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Card pushed down so logo overlaps slightly
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
                            // Title
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text:
                                    '"Welcome back! continue where you left off.\n',
                                  ),
                                  TextSpan(
                                    text: 'Sign in now!"',
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
                              decoration: _dec('enter your  phone number'),
                            ),
                            SizedBox(height: 12.h),

                            // Username
                            TextFormField(
                              controller: controller.usernameCtrl,
                              textInputAction: TextInputAction.done,
                              validator: controller.validateUsername,
                              decoration: _dec('username'),
                            ),

                            // Forget Password? right-aligned
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: navigate to forgot password
                                  // Get.toNamed(AppPages.forgotPassword);
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.only(top: 6.h),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Forget Password?',
                                  style: TextStyle(color: Color(0xFF3B82F6)),
                                ),
                              ),
                            ),

                            SizedBox(height: 6.h),

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
                                  child: Text(busy ? 'Please wait…' : 'confirm'),
                                ),
                              );
                            }),

                            SizedBox(height: 16.h),

                            // Sign up text (two lines, centered)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'If you don’t have an account, just',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF2E2E2E),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                   // Get.toNamed(AppPages.pages); // link to Sign Up
                                  },
                                  child: Text(
                                    'Sign up now!',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
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

                // Side illustrations
                Positioned(
                  left: -8.w,
                  bottom: -16.h,
                  child: Image.asset(
                    'assets/png/woman.png',
                    height: 160.h,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  right: -8.w,
                  bottom: -32.h,
                  child: Image.asset(
                    'assets/png/man.png',
                    height: 168.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
