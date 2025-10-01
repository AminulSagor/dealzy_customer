import 'package:get/get.dart';

class WelcomeController extends GetxController {

  final isBusy = false.obs;

  void onNext() {

    Get.toNamed('/home');
  }
}
