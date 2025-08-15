import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_setting_controller.dart';

class ProfileSettingView extends GetView<ProfileSettingController> {
  const ProfileSettingView({super.key});

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
          children: [
            // Name
            ListTile(
              title: Text(controller.name.value),
              onTap: () => controller.editField(
                title: 'Name',
                target: controller.name,
                hint: 'Your full name',
              ),
            ),
            divider,

            // Set Password
            ListTile(
              title: const Text('Set Password'),
              onTap: controller.setPassword,
            ),
            divider,

            // Phone
            ListTile(
              title: Text(controller.phone.value),
              onTap: () => controller.editField(
                title: 'Phone',
                target: controller.phone,
                keyboardType: TextInputType.phone,
                validator: controller.validatePhone,
                hint: '+8801xxxxxxxxx',
              ),
            ),
            divider,

            // Email
            ListTile(
              title: Text(controller.email.value),
              onTap: () => controller.editField(
                title: 'Email',
                target: controller.email,
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
                hint: 'you@example.com',
              ),
            ),
            divider,

            // Location
            ListTile(
              title: Text(controller.location.value),
              onTap: () async {
                // TODO: open your location picker / permission flow
                // For now, just quick edit:
                await controller.editField(
                  title: 'Location',
                  target: controller.location,
                  hint: 'City / Area',
                );
              },
            ),
            divider,
          ],
        );
      }),
    );
  }
}
