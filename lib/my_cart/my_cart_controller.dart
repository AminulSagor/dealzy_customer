import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyCartController extends GetxController {
  final RxBool selectAll = false.obs;
  final RxList<CartItem> items = <CartItem>[].obs;

  /// ✅ Loading state for mock API
  final RxBool isLoading = false.obs;

  /// ✅ Scroll controller for detecting scroll events
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    /// Initially load mock data
    fetchCartItems();

    /// Attach scroll listener
    scrollController.addListener(_onScroll);
  }

  /// ✅ Simulate API call (mock)
  Future<void> fetchCartItems() async {
    isLoading.value = true;

    // Mock API delay
    await Future.delayed(const Duration(seconds: 2));

    // Mocked API response (same data)
    items.assignAll([
      CartItem(
        storeId: "store_1",
        storeName: "T.gfstore",
        productName: "JBL Tube 489",
        brandName: "Brand name",
        price: 100,
        quantity: 1,
        isAvailable: false,
        imageUrl: "assets/png/mouse.jpg",
      ),
      CartItem(
        storeId: "store_1",
        storeName: "T.gfstore",
        productName: "JBL Tube 489",
        brandName: "Brand name",
        price: 100,
        quantity: 1,
        isAvailable: false,
        imageUrl: "assets/png/mouse.jpg",
      ),
      CartItem(
        storeId: "store_1",
        storeName: "T.gfstore",
        productName: "JBL Tube 489",
        brandName: "Brand name",
        price: 100,
        quantity: 1,
        isAvailable: false,
        imageUrl: "assets/png/mouse.jpg",
      ),
      CartItem(
        storeId: "store_1",
        storeName: "T.gfstore",
        productName: "JBL Tube 489",
        brandName: "Brand name",
        price: 100,
        quantity: 1,
        isAvailable: false,
        imageUrl: "assets/png/mouse.jpg",
      ),
      CartItem(
        storeId: "store_1",
        storeName: "T.gfstore",
        productName: "JBL Tube 489",
        brandName: "Brand name",
        price: 100,
        quantity: 1,
        isAvailable: true,
        imageUrl: "assets/png/mouse.jpg",
      ),
      CartItem(
        storeId: "store_2",
        storeName: "TechX Store",
        productName: "Sony WH-1000XM4",
        brandName: "Sony",
        price: 120,
        quantity: 1,
        isAvailable: true,
        imageUrl: "assets/png/mouse.jpg",
      ),
      CartItem(
        storeId: "store_2",
        storeName: "TechX Store",
        productName: "Bose QC45",
        brandName: "Bose",
        price: 150,
        quantity: 1,
        isAvailable: true,
        imageUrl: "assets/png/mouse.jpg",
      ),
    ]);

    isLoading.value = false;
  }

  /// ✅ Scroll listener
  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 100) {
      // You reached near bottom (you can load more here)
      debugPrint("🔽 Reached bottom of cart list");
    }
  }

  /// ✅ Select / Deselect all
  void toggleSelectAll(bool? value) {
    selectAll.value = value ?? false;
    for (final item in items) {
      item.isSelected.value = selectAll.value;
    }
  }

  void toggleStoreSelection(String storeId, bool? value) {
    final target = items.where((e) => e.storeId == storeId);
    for (var item in target) {
      item.isSelected.value = value ?? false;
    }
    selectAll.value = items.every((e) => e.isSelected.value);
  }

  void removeItem(CartItem item) => items.remove(item);

  void bulkDelete() {
    items.removeWhere((item) => item.isSelected.value);
    selectAll.value = false;
  }

  void toggleItem(CartItem item) {
    item.isSelected.toggle();
    selectAll.value = items.every((e) => e.isSelected.value);
  }

  List<StoreGroup> get groupedItems {
    final Map<String, List<CartItem>> map = {};
    for (var item in items) {
      map.putIfAbsent(item.storeId, () => []).add(item);
    }
    return map.entries
        .map((e) => StoreGroup(
      storeId: e.key,
      storeName: e.value.first.storeName,
      items: e.value,
    ))
        .toList();
  }

  /// ✅ Quantity adjustments
  void increaseQuantity(CartItem item) => item.quantity.value++;
  void decreaseQuantity(CartItem item) {
    if (item.quantity.value > 1) item.quantity.value--;
  }

  int get selectedCount =>
      items.where((e) => e.isSelected.value).length;

  double get totalSelectedPrice => items
      .where((e) => e.isSelected.value)
      .fold(0, (sum, e) => sum + e.price * e.quantity.value);

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}

class CartItem {
  final String storeId;
  final String storeName;
  final String productName;
  final String brandName;
  final double price;
  final bool isAvailable;
  final String imageUrl;
  RxBool isSelected = false.obs;
  RxInt quantity;

  CartItem({
    required this.storeId,
    required this.storeName,
    required this.productName,
    required this.brandName,
    required this.price,
    required int quantity,
    required this.isAvailable,
    required this.imageUrl,
  }) : quantity = quantity.obs;
}

class StoreGroup {
  final String storeId;
  final String storeName;
  final List<CartItem> items;
  StoreGroup({
    required this.storeId,
    required this.storeName,
    required this.items,
  });
}
