import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/app_bottom_nav.dart';
import 'notification_controller.dart';
import '../routes/app_pages.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final bgPeach = const Color(0xFFF6EDE8); // soft peach like the mock
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: const Color(0xFF1C1C1C),
    );
    final bodyStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: const Color(0xFF333333),
      height: 1.35,
    );
    final timeStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: const Color(0xFF5A5A5A),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 16.w,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Notifications',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        return ListView.separated(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
          itemCount: controller.items.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (_, i) {
            final n = controller.items[i];
            return Container(
              decoration: BoxDecoration(
                color: bgPeach,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              padding: EdgeInsets.all(12.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/png/fire_icon.png',   // ensure in pubspec.yaml
                    width: 28.w,
                    height: 28.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.title, style: titleStyle),
                        SizedBox(height: 4.h),
                        Text(n.body, style: bodyStyle),
                        SizedBox(height: 6.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(n.time, style: timeStyle),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
      // Reusable bottom navigation
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
