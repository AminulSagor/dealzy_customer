import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Adjust these two to fine-tune overlap
    final double logoHeight = 180.h; // logo render height
    final double cardTopOffset = 130.h; // how far the card starts below the top of the stack

    return Scaffold(
      backgroundColor: const Color(0xFF124A89),
      body: Padding(
        padding: EdgeInsets.only(top: 160.h),
        child: SafeArea(

            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // Card placed lower to allow the logo to overlap it
                    Padding(
                      padding: EdgeInsets.only(top: cardTopOffset),
                      child: _WelcomeCard(theme: theme, controller: controller),
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
                  ],
                ),
              ),
            ),

        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.theme,
    required this.controller,
  });

  final ThemeData theme;
  final WelcomeController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'welcome',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text:
                    'Discover real-time deals from nearby grocery and convenience stores. Save money, reduce food waste, and support your local shops — all in one loop. ',
                  ),
                  TextSpan(
                    text: 'Let’s shop smarter, together.',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.35,
                  color: const Color(0xFF2E2E2E),
                ),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: 0.72.sw,
              height: 48.h,
              child: Obx(() {
                final base = const Color(0xFF124A89);
                return ElevatedButton(
                  onPressed: controller.isBusy.value ? null : controller.onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: base,
                    foregroundColor: Colors.white, // text & icon
                    disabledBackgroundColor: base.withOpacity(0.5),
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ).copyWith(
                    overlayColor: MaterialStateProperty.resolveWith(
                          (states) => states.contains(MaterialState.pressed)
                          ? base.withOpacity(0.85)
                          : null,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Next'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios_rounded, size: 18),
                    ],
                  ),
                );
              }),
            )

          ],
        ),
      ),
    );
  }
}
