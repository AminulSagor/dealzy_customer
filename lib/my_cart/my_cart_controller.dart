import 'package:dealzy/my_cart/product_options_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import 'get_carts_service.dart';

enum CartRowState { normal, deleting, success, error }

class MyCartController extends GetxController {
  final GetCartsService _cartService = GetCartsService();
  final ProductOptionsService _productOptionsService = ProductOptionsService();

  /// ✅ Observables
  final RxBool isLoading = false.obs;
  final RxBool selectAll = false.obs;
  final RxList<CartItem> items = <CartItem>[].obs;
  final Rxn<SellerInfo> seller = Rxn<SellerInfo>();

  final RxBool isOptionsLoading = false.obs;
  final RxBool isCheckoutLoading = false.obs;

  ///temp for coin
  Map<String, int> coinData = {};

  /// ✅ Scroll controller for lazy loading (if needed later)
  final ScrollController scrollController = ScrollController();

  // 🔹 holds current visual state per cart item
  final RxMap<String, CartRowState> rowStates = <String, CartRowState>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCartItems();
    scrollController.addListener(_onScroll);
  }

  // convenience getter
  CartRowState rowStateFor(String cartId) {
    return rowStates[cartId] ?? CartRowState.normal;
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
        coinData['available'] = response.availableCoins;
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
      final colors = await _productOptionsService.getProductColors(productId);
      final variants = await _productOptionsService.getProductVariants(
        productId,
      );

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
    } catch (e) {
      isOptionsLoading.value = false;
    } finally {
      isOptionsLoading.value = false;
    }
  }

  /// ✅ Scroll listener (optional lazy load)
  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 100) {}
  }

  void onCheckout() async {
    List<CartItem>? selectedItems;
    isCheckoutLoading.value = true;

    for (int i = 0; i < items.length; i++) {
      if (items[i].isSelected.value) {
        selectedItems ??= [];
        if (items[i].selectedColor.value == null ||
            items[i].selectedVariant.value == null) {
          await fetchColorsAndVariants(items[i].productId, i);
        }
        selectedItems.add(items[i]);
      }
    }

    isCheckoutLoading.value = false;

    Get.toNamed(
      AppRoutes.orderConfirmation,
      arguments: {'items': selectedItems, 'coinData': coinData},
    );
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

  /// 🔹 Called when user swipes to delete an item
  Future<void> handleSwipeDelete(String cartId) async {
    // mark as deleting (spinner state)
    rowStates[cartId] = CartRowState.deleting;

    try {
      final ok = await _cartService.deleteCartItem(
        cartId,
      ); // <-- uses your service
      if (ok) {
        // success visual
        rowStates[cartId] = CartRowState.success;

        // brief "green tick" moment before actually removing the row
        await Future.delayed(const Duration(milliseconds: 500));

        // remove from list
        items.removeWhere((i) => i.cartId == cartId);

        // if cart is now empty, clear seller etc. (optional)
        if (items.isEmpty) {
          seller.value = null;
        }

        // cleanup tracking
        rowStates.remove(cartId);
      } else {
        // show failure state briefly (red)
        rowStates[cartId] = CartRowState.error;
        await Future.delayed(const Duration(milliseconds: 800));

        // bounce back to normal view
        rowStates[cartId] = CartRowState.normal;
      }
    } catch (e) {
      // also treat as failure
      rowStates[cartId] = CartRowState.error;
      await Future.delayed(const Duration(milliseconds: 800));
      rowStates[cartId] = CartRowState.normal;
    }
  }

  /// Delete all currently selected items using the API.
  /// Each row will animate through the same states as swipe delete.
  Future<void> bulkDelete() async {
    // Take a snapshot of selected items first,
    // so we don't mutate the list while iterating.
    final toDelete = items.where((i) => i.isSelected.value).toList();

    // Nothing selected? just bail.
    if (toDelete.isEmpty) return;

    for (final cartItem in toDelete) {
      final cartId = cartItem.cartId;

      // mark row "deleting" for spinner state
      rowStates[cartId] = CartRowState.deleting;

      try {
        final ok = await _cartService.deleteCartItem(cartId);

        if (ok) {
          // mark success so UI shows green tick
          rowStates[cartId] = CartRowState.success;

          // brief success flash
          await Future.delayed(const Duration(milliseconds: 500));

          // remove from list
          items.removeWhere((i) => i.cartId == cartId);

          // cleanup tracking for that row
          rowStates.remove(cartId);
        } else {
          // API said not success -> show error briefly
          rowStates[cartId] = CartRowState.error;
          await Future.delayed(const Duration(milliseconds: 800));
          rowStates[cartId] = CartRowState.normal;
        }
      } catch (e) {
        // network/other failure -> show error briefly then reset
        rowStates[cartId] = CartRowState.error;
        await Future.delayed(const Duration(milliseconds: 800));
        rowStates[cartId] = CartRowState.normal;
      }
    }

    // After loop cleanup
    selectAll.value = false;

    // If cart is now empty, clear seller so UI shows "Cart is empty"
    if (items.isEmpty) {
      seller.value = null;
    }
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
