// widgets/login_required_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

class LoginRequiredDialog extends StatelessWidget {
  const LoginRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Login Required',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text('You must log in to access this feature.'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: [
        TextButton(
          onPressed: () => Get.back(), // just close
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF124A89),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Get.back(); // close dialog
            Get.offAllNamed(AppRoutes.signIn);// navigate to your login screen route
          },
          child: const Text(
            'Login',
            style: TextStyle(
              color: Colors.white, // <-- white text
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
