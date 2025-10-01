import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'update_password_controller.dart';



class UpdatePasswordView extends GetView<UpdatePasswordController> {
  const UpdatePasswordView({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF124A89),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(), // go back to previous screen
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF114B84),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).viewInsets.bottom -
                  24.h,
            ),
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // Card
                  Container(
                    width: 350.w,
                    constraints: BoxConstraints(maxWidth: 520.w),
                    padding: EdgeInsets.fromLTRB(18.w, 60.h, 18.w, 20.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'New Password',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D3238),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Your new password must be at least 8 characters long, including one uppercase letter, number, and symbol.',
                          style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        // ↓↓↓ changed: destination -> email
                        if (controller.email.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Text(
                            controller.email,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D3238),
                            ),
                          ),
                        ],
                        SizedBox(height: 16.h),

                        // New password
                        Obx(() => TextField(
                          controller: controller.newPwdCtrl,
                          focusNode: controller.newPwdNode,
                          obscureText: controller.obscureNew.value,
                          keyboardType: TextInputType.visiblePassword,
                          enableSuggestions: false,
                          autocorrect: false,
                          onSubmitted: (_) =>
                              controller.confirmPwdNode.requestFocus(),
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Enter your new password',
                            isDense: true,
                            errorText: controller.newPwdError.value,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.h, horizontal: 14.w),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            suffixIcon: IconButton(
                              onPressed: controller.obscureNew.toggle,
                              icon: Icon(controller.obscureNew.value
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            ),
                          ),
                        )),
                        SizedBox(height: 12.h),

                        // Confirm password
                        Obx(() => TextField(
                          controller: controller.confirmPwdCtrl,
                          focusNode: controller.confirmPwdNode,
                          obscureText: controller.obscureConfirm.value,
                          keyboardType: TextInputType.visiblePassword,
                          enableSuggestions: false,
                          autocorrect: false,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => controller.submit(),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Confirm your new password',
                            isDense: true,
                            errorText: controller.confirmPwdError.value,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.h, horizontal: 14.w),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            suffixIcon: IconButton(
                              onPressed: controller.obscureConfirm.toggle,
                              icon: Icon(controller.obscureConfirm.value
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            ),
                          ),
                        )),

                        SizedBox(height: 18.h),

                        // Confirm button
                        SizedBox(
                          width: 180.w,
                          height: 44.h,
                          child: Obx(() {
                            final enabled = controller.canSubmit.value &&
                                !controller.isSubmitting.value;
                            return ElevatedButton(
                              onPressed: enabled ? controller.submit : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF124A89),
                                disabledBackgroundColor:
                                const Color(0xFFBFC9D3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: controller.isSubmitting.value
                                  ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                                  : Text(
                                'Confirm', // ← capitalized
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  // Logo
                  Positioned(
                    top: -120.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        'assets/png/logo.png',
                        width: 160,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


