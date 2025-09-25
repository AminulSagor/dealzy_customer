// lib/combine_service/connection_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

class ConnectionService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  // Expose current status if you need it elsewhere
  final isConnected = true.obs;

  Future<ConnectionService> init() async {
    // initial status
    final results = await _connectivity.checkConnectivity();           // v6: List<ConnectivityResult>
    _updateConnectionStatus(results);

    // watch changes
    _subscription = _connectivity.onConnectivityChanged               // v6: Stream<List<ConnectivityResult>>
        .listen(_updateConnectionStatus);

    return this;
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // if ANY interface is available, we're "connected"
    final hasInternet = results.any((r) => r != ConnectivityResult.none);
    isConnected.value = hasInternet;

    if (!hasInternet) {
      if (Get.currentRoute != AppRoutes.noInternet) {
        Get.toNamed(AppRoutes.noInternet);
      }
    } else {
      if (Get.currentRoute == AppRoutes.noInternet && Get.key.currentState!.canPop()) {
        Get.back();
      }
      // (optional) else: keep user where they are
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
