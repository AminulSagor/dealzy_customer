import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'combine_service/connection_service.dart';
import 'combine_service/push_service.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'storage/first_launch_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  await PushService.init();
  await Get.putAsync(() => ConnectionService().init());

  // Decide the first screen while native splash is still showing
  final isFirst = await FirstLaunchStorage.isFirstLaunch();
  if (isFirst) {
    await FirstLaunchStorage.setLaunched();
  }

  runApp(MyApp(initialRoute: isFirst ? AppRoutes.home : AppRoutes.home));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute});
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (_, __) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Dealzy',
          initialRoute: initialRoute, // <-- no more Splash route
          getPages: AppPages.pages,
        );
      },
    );
  }
}
