import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'get_carts_service.dart';

class MyCartController extends GetxController {
  final GetCartsService _cartService = GetCartsService();

  /// ✅ Observables
  final RxBool isLoading = false.obs;
  final RxBool selectAll = false.obs;
  final RxList<CartItem> items = <CartItem>[].obs;
  final Rxn<SellerInfo> seller = Rxn<SellerInfo>();

  final RxBool isOptionsLoading = false.obs;

  ///temp for coin
  Map<String, int> coinData = {};

  /// ✅ Scroll controller for lazy loading (if needed later)
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchCartItems();
    scrollController.addListener(_onScroll);
  }

  /// ✅ Fetch from real API
  Future<void> fetchCartItems() async {
    try {
      isLoading.value = true;
      final response = await _cartService.getCarts();

      if (response.isSuccess) {
        seller.value = response.seller;
        items.assignAll(response.carts);

        //temp for coin
        coinData['available'] = 100;
        // response.availableCoins;
        coinData['minimum'] = response.minimumUse;
      } else {
        Get.snackbar('Error', 'Failed to load cart items');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchColorsAndVariants(String productId, int index) async {
    try {
      isOptionsLoading.value = true;
      final colors = await _cartService.getProductColors(productId);
      final variants = await _cartService.getProductVariants(productId);

      items[index].colors = colors;
      items[index].variants = variants;

      if (colors.isNotEmpty) {
        items[index].selectedColor.value = colors.first;
      } else {
        items[index].selectedColor.value = null;
      }
      if (variants.isNotEmpty) {
        items[index].selectedVariant.value = variants.first;
      } else {
        items[index].selectedVariant.value = null;
      }

      debugPrint(
        '✅ ${items[index].productName} | ${items[index].productId} => ${colors.length} colors, ${variants.length} variants',
      );
    } catch (e) {
      isOptionsLoading.value = false;
      debugPrint(
        '⚠️ Error fetching extras for ${items[index].productName}: $e',
      );
    } finally {
      isOptionsLoading.value = false;
    }
  }

  /// ✅ Scroll listener (optional lazy load)
  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 100) {
      debugPrint("🔽 Reached bottom of cart list");
    }
  }

  /// ✅ Selection controls
  void toggleSelectAll(bool? value) {
    selectAll.value = value ?? false;
    for (final item in items) {
      if (item.isAvailable) {
        item.isSelected.value = selectAll.value;
      } else {
        item.isSelected.value = false;
      }
    }
  }

  void toggleItem(CartItem item) {
    item.isSelected.toggle();
    selectAll.value = items.every((e) => e.isSelected.value);
  }

  /// ✅ Quantity adjustments
  void increaseQuantity(CartItem item) {
    if (item.quantity.value < item.stock) {
      item.quantity.value++;
    }
  }

  void decreaseQuantity(CartItem item) {
    if (item.quantity.value > 1) item.quantity.value--;
  }

  /// ✅ Remove single or multiple
  void removeItem(CartItem item) {
    items.remove(item);
    if (items.isEmpty) {
      seller.value = null;
    }
  }

  void bulkDelete() {
    items.removeWhere((item) => item.isSelected.value);
    if (items.isEmpty) {
      seller.value = null;
    }
    selectAll.value = false;
  }

  /// ✅ Computed properties
  int get selectedCount => items.where((e) => e.isSelected.value).length;

  double get totalSelectedPrice => items
      .where((e) => e.isSelected.value)
      .fold(0, (sum, e) => sum + e.price * e.quantity.value);

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
