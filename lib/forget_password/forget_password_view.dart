import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'forget_password_controller.dart';

class ForgetPasswordView extends GetView<ForgetPasswordController> {
  const ForgetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF124A89), // blue bg
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(), // go back to previous screen
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 520.w),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // --- Card ---------------------------------------------------------
                  Container(
                    margin: EdgeInsets.only(top: 40.h), // space for overlapping logo
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6.r,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 8.h), // keeps header away from the logo edge
                        Text(
                          "Forget Password",
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "To reset your password, enter your email address, "
                              "verify with an OTP, and create a new password.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                        ),
                        SizedBox(height: 20.h),

                        // Email input
                        TextField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Enter your email",
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Confirm button
                        SizedBox(
                          width: double.infinity,
                          child: Obx(() => ElevatedButton(
                            onPressed: controller.isSubmitting.value
                                ? null
                                : controller.submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF124A89),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: controller.isSubmitting.value
                                ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white,
                              ),
                            )
                                : Text(
                              "Confirm",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          )),
                        ),
                      ],
                    ),
                  ),

                  // --- Overlapping logo --------------------------------------------
                  Positioned(
                    top: -80, // negative to overlap
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(6),

                        child: Image.asset(
                          'assets/png/logo.png', // 👈 your logo
                          width: 160,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )

      ),
    );
  }
}
