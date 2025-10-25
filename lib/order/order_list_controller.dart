import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class OrderModel {
  final String id;
  final String image;
  final String status;
  final String orderCode;
  final double amount;
  final DateTime date;
  final bool canCancel; // 🔹 mock backend flag

  OrderModel({
    required this.id,
    required this.image,
    required this.status,
    required this.orderCode,
    required this.amount,
    required this.date,
    this.canCancel = false,
  });
}

class OrderListController extends GetxController {
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final ScrollController scrollController = ScrollController();

  int currentPage = 1;
  int totalPages = 3;

  @override
  void onInit() {
    super.onInit();
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

  Future<void> fetchOrders() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));

    final status = Get.arguments?['status'] ?? 'Pending';
    final newOrders = List.generate(
      10,
      (index) => OrderModel(
        id: 'ORD-${currentPage}0$index',
        image: 'https://avatar.iran.liara.run/public',
        status: status,
        orderCode: _generateCode(),
        amount: 15 + Random().nextInt(80) + 0.99,
        date: DateTime.now().subtract(Duration(days: index * 2)),

        // 🔹 Mocked cancel flag
        canCancel:
            (status == 'Pending') ||
            (status != 'Delivered' && Random().nextBool()),
      ),
    );

    orders.assignAll(newOrders);
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (currentPage >= totalPages) return;
    isLoadingMore.value = true;
    await Future.delayed(const Duration(seconds: 2));

    final nextPage = currentPage + 1;
    final status = Get.arguments?['status'] ?? 'Pending';
    final newOrders = List.generate(
      10,
      (index) => OrderModel(
        id: 'ORD-${nextPage}0$index',
        image: 'https://avatar.iran.liara.run/public',
        status: status,
        orderCode: _generateCode(),
        amount: 15 + Random().nextInt(80) + 0.99,
        date: DateTime.now().subtract(Duration(days: index * 3)),
        canCancel:
            (status == 'Pending') ||
            (status != 'Delivered' && Random().nextBool()),
      ),
    );

    orders.addAll(newOrders);
    currentPage = nextPage;
    isLoadingMore.value = false;
  }

  void cancelOrder(OrderModel order) {
    orders.remove(order);
    Get.snackbar(
      "Order Cancelled",
      "Order ${order.orderCode} has been cancelled.",
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
