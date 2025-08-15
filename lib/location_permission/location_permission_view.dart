import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'location_permission_controller.dart';

class LocationPermissionView extends GetView<LocationPermissionController> {
  const LocationPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // spacing/overlap
    final double logoHeight = 180.h;
    final double overlap = 54.h;

    final double mapArtHeight = 205.h;
    final double pinSize = 92.h;

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
                // Card pushed down so the logo can overlap
                Padding(
                  padding: EdgeInsets.only(top: logoHeight - overlap),
                  child: Card(
                    elevation: 3,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // FULL-BLEED HEADER (touches card sides)
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            // inside the Stack that builds the header
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.r),
                                topRight: Radius.circular(16.r),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: mapArtHeight,
                                child: Transform(
                                  alignment: Alignment.center,
                                  // widen horizontally only; keep height the same
                                  transform: Matrix4.diagonal3Values(1.35, 1.0, 1.0), // try 1.2–1.4
                                  child: Image.asset(
                                    'assets/png/design_behind_location_icon.png',
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              bottom:  55, // overlap into content
                              child: Image.asset(
                                'assets/png/location_icon.png',
                                height: pinSize,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),

                        // BODY with padding (separate from header)
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            16.w,
                            1.h, // space for the overlapping pin
                            16.w,
                            20.h,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Allow us to access your location to provide better service and accurate results.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF2E2E2E),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16.h),
                              SizedBox(
                                width: 0.78.sw,
                                height: 48.h,
                                child: Obx(() {
                                  final busy = controller.isBusy.value;
                                  return ElevatedButton(
                                    onPressed: busy ? null : controller.requestLocation,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF124A89),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                      const Color(0xFF124A89).withOpacity(0.5),
                                      disabledForegroundColor: Colors.white70,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14.r),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.location_on_outlined),
                                        SizedBox(width: 10.w),
                                        Text(
                                          busy ? 'Please wait…' : 'Get Location',
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
