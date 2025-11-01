import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'get_customer_orders_service.dart';

class OrderListController extends GetxController {
  final RxList<SellerOrders> sellers = <SellerOrders>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final ScrollController scrollController = ScrollController();

  int currentPage = 1;
  int totalPages = 1;
  final int limit = 10;
  late String status;

  final _service = GetCustomerOrdersService();

  @override
  void onInit() {
    super.onInit();
    status = (Get.arguments?['status'] ?? 'pending').toString().toLowerCase();
    fetchOrders();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore.value &&
        currentPage < totalPages) {
      loadMore();
    }
  }

  /// 🔹 Fetch first page
  Future<void> fetchOrders() async {
    isLoading.value = true;
    currentPage = 1;

    try {
      final res = await _service.getCustomerOrders(
        status: status,
        page: currentPage,
        limit: limit,
      );

      if (res.isSuccess) {
        sellers.assignAll(res.sellers);
        totalPages = res.pagination.totalPages;
      } else {
        sellers.clear();
        Get.snackbar("Error", "Failed to fetch orders.");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      sellers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Load next page for infinite scroll
  Future<void> loadMore() async {
    if (currentPage >= totalPages) return;
    isLoadingMore.value = true;

    try {
      final nextPage = currentPage + 1;

      final res = await _service.getCustomerOrders(
        status: status,
        page: nextPage,
        limit: limit,
      );

      if (res.isSuccess && res.sellers.isNotEmpty) {
        sellers.addAll(res.sellers);
        currentPage = nextPage;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 🔹 Generate code for a specific order (from /generate_unicode.php)
  final RxMap<String, String> orderCodes = <String, String>{}.obs;
  final RxSet<String> loadingCodes = <String>{}.obs;

  Future<void> generateOrderCode(String orderId) async {
    if (orderCodes.containsKey(orderId)) return; // already loaded
    loadingCodes.add(orderId);

    try {
      final code = await _service.generateUnicode(orderId);
      if (code != null) {
        orderCodes[orderId] = code;
      } else {
        Get.snackbar("Error", "Failed to generate code for order $orderId");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      loadingCodes.remove(orderId);
    }
  }

  /// 🔹 Cancel Order API Call
  final RxSet<String> cancellingOrders = <String>{}.obs;

  Future<void> cancelOrder(String orderId) async {
    if (cancellingOrders.contains(orderId)) return;
    cancellingOrders.add(orderId);

    try {
      final res = await _service.cancelOrderRequest(orderId);

      // If success, remove it
      if (res.isSuccess) {
        // remove order with that ID from sellers list
        for (final seller in sellers) {
          seller.orders.removeWhere((o) => o.orderId == orderId);
        }

        fetchOrders();
      }
    } catch (e) {
      // handle failure UI however you like
      Get.snackbar("Error", e.toString());
    } finally {
      cancellingOrders.remove(orderId);
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
