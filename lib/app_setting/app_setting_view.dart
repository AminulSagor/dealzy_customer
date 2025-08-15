import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_setting_controller.dart';

class AppSettingView extends GetView<AppSettingController> {
  const AppSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final divider = const Divider(height: 1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          children: [
            // Account Settings
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Account Settings'),
              trailing: const Icon(Icons.expand_more_rounded, color: Colors.black87),
              onTap: controller.openAccountSettings,
            ),
            divider,

            // Country
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(controller.country.value),
              trailing: const Icon(Icons.expand_more_rounded, color: Colors.black87),
              onTap: controller.pickCountry,
            ),
            divider,

            // Language
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(controller.language.value),
              trailing: const Icon(Icons.expand_more_rounded, color: Colors.black87),
              onTap: controller.pickLanguage,
            ),
            divider,

            // Need Help
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Need Help?'),
              onTap: controller.needHelp,
            ),

            SizedBox(height: 48.h),

            // Centered Log Out
            Center(
              child: TextButton.icon(
                onPressed: controller.logout,
                icon: const Icon(Icons.logout_rounded, color: Colors.black87),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        );
      }),
    );
  }
}
