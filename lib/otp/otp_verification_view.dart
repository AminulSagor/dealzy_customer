import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'otp_verification_controller.dart';

class OtpVerificationView extends GetView<OtpVerificationController> {
  const OtpVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final isKbOpen = MediaQuery.of(context).viewInsets.bottom > 0;

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
                  24.h, // fill available height
            ),
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // --- Card ---
                  Container(
                    width: 350.w,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Otp Verification Code',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D3238),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'A 6 digits OTP has been sent to your email',
                          style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          controller.destination,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D3238),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 18.h),

                        _OtpBoxes(controller: controller),

                        SizedBox(height: 18.h),

                        SizedBox(
                          width: 160.w,
                          height: 44.h,
                          child: Obx(() {
                            final enabled = controller.canSubmit.value &&
                                !controller.isSubmitting.value;
                            return ElevatedButton(
                              onPressed: enabled ? controller.submit : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF124A89),
                                disabledBackgroundColor: const Color(0xFFBFC9D3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              child: Obx(
                                    () => controller.isSubmitting.value
                                    ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : Text(
                                  'Confirm',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  // --- Overlapping Logo ---
                  Positioned(
                    top: -120, // negative to overlap
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


        ),
      ),
    );
  }
}

class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({required this.controller});
  final OtpVerificationController controller;

  @override
  Widget build(BuildContext context) {
    final boxes = List.generate(controller.otpLength, (i) {
      final isLast = i == controller.otpLength - 1;

      return SizedBox(
        width: 44.w,
        child: Focus(
          focusNode: controller.nodes[i],
          onKey: (node, event) => controller.onDigitKey(node, event, i), // RawKeyEvent API
          child: TextField(
            controller: controller.ctrls[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            // keep the keyboard open & move explicitly
            textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
            onEditingComplete: () {
              if (!isLast) {
                controller.nodes[i + 1].requestFocus();
              }
            },
            onSubmitted: (_) {
              if (!isLast) {
                controller.nodes[i + 1].requestFocus();
              } else {
                controller.submit();
              }
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            // ensure field scrolls above keyboard on small screens
            scrollPadding: EdgeInsets.only(bottom: 140.h),
            onChanged: (val) => controller.onDigitChanged(i, val),
          ),
        ),
      );
    });

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      alignment: WrapAlignment.center,
      children: boxes,
    );
  }
}
