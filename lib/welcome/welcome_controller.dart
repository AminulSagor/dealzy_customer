import 'package:get/get.dart';

class WelcomeController extends GetxController {
  // Any async prep can go here later
  final isBusy = false.obs;

  void onNext() {
    // TODO: replace with your actual next route
    Get.toNamed('/home');
  }
}
