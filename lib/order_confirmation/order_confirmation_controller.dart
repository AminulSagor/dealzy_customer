import 'package:dealzy/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../my_cart/get_carts_service.dart';
import 'get_discount_service.dart';
import 'place_order_service.dart';

class OrderConfirmationController extends GetxController {
  final RxList<CartItem> items = <CartItem>[].obs;
  final RxDouble discount = 0.0.obs;
  final RxString voucher = ''.obs;
  final RxString coin = ''.obs;

  // 🔹 Coin-related fields
  final RxInt availableCoins = 0.obs;
  final RxInt minimumUse = 0.obs;
  final RxInt usedCoins = 0.obs;

  // 🔹 Loading state for API call
  final RxBool isApplying = false.obs;
  final RxBool isPlacingOrder = false.obs;

  final _discountService = GetDiscountService();
  final _orderService = PlaceOrderService();

  final TextEditingController noteController = TextEditingController();

  double get subtotal =>
      items.fold(0, (sum, e) => sum + e.price * e.quantity.value);

  double get coinValue => usedCoins.value * 0.1; // each coin worth £0.10
  double get total =>
      (subtotal - discount.value - coinValue).clamp(0, double.infinity);

  @override
  void onInit() {
    super.onInit();
    final argItems = Get.arguments['items'] as List<CartItem>?;
    final argCoindata = Get.arguments['coinData'] as Map<String, int>?;

    if (argItems != null) items.assignAll(argItems);
    if (argCoindata != null) {
      availableCoins.value = argCoindata['available'] ?? 0;
      minimumUse.value = argCoindata['minimum'] ?? 0;
    }
  }

  /// 🟦 Combine voucher + coin usage into one function
  Future<void> applyDiscount({String? voucherCode, int? coinsToUse}) async {
    if (subtotal <= 0) {
      Get.snackbar("Cart Empty", "Please add items before applying discount.");
      return;
    }

    isApplying.value = true;
    usedCoins.value = 0;
    discount.value = 0; // reset before call

    try {
      final res = await _discountService.estimateDiscount(
        subTotal: subtotal,
        coupon: voucherCode,
        coins: coinsToUse,
      );

      if (res.isSuccess) {
        final theMsg = res.message.toLowerCase();

        if (theMsg.contains('added')) {
          discount.value = res.discount;
          voucher.value = voucherCode ?? '';
          usedCoins.value = coinsToUse ?? 0;
          _showDialog(
            title: "Discount Applied!",
            message: res.message.isNotEmpty
                ? res.message
                : "Your discount has been successfully applied.",
            icon: Icons.celebration_rounded,
            iconColor: Colors.green,
            buttonText: "OK",
            buttonColor: const Color(0xFF124A89),
          );
        } else if (theMsg.contains('invalid')) {
          _showDialog(
            title: "No Discount",
            message: res.message.isNotEmpty
                ? res.message
                : "No valid coupon or coins applied.",
            icon: Icons.info_outline,
            iconColor: Colors.redAccent,
            buttonText: "OK",
            buttonColor: Colors.redAccent,
          );
        }
      } else {
        _showDialog(
          title: "No Discount",
          message: res.message.isNotEmpty
              ? res.message
              : "No valid coupon or coins applied.",
          icon: Icons.info_outline,
          iconColor: Colors.redAccent,
          buttonText: "OK",
          buttonColor: Colors.redAccent,
        );
      }
    } catch (e) {
      _showDialog(
        title: "Error",
        message: e.toString().replaceAll('Exception:', '').trim(),
        icon: Icons.error_outline,
        iconColor: Colors.redAccent,
        buttonText: "Try Again",
        buttonColor: Colors.redAccent,
      );
    } finally {
      isApplying.value = false;
    }
  }

  /// 🟦 Place order API integration
  Future<void> onConfirmOrder() async {
    if (items.isEmpty) {
      Get.snackbar("No Items", "Please add items to your cart first.");
      return;
    }

    isPlacingOrder.value = true;

    try {
      final orderItems = items.map((e) {
        return OrderItem(
          cartId: e.cartId,
          quantity: e.quantity.value,
          rate: e.price,
          colorId: e.selectedColor.value?.id,
          variantId: e.selectedVariant.value?.id,
        );
      }).toList();

      final response = await _orderService.placeOrder(
        discount: discount.value,
        notes: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
        items: orderItems,
      );

      if (response.isSuccess) {
        _showOrderDialog(
          title: "Order Placed 🎉",
          message: response.message.isNotEmpty
              ? response.message
              : "Your order has been created successfully.",
        );
      } else {
        _showOrderDialog(
          success: false,
          title: "Order Failed",
          message: response.message.isNotEmpty
              ? response.message
              : "Could not place order. Please try again.",
        );
      }
    } catch (e) {
      _showOrderDialog(
        success: false,
        title: "Error",
        message: e.toString().replaceAll('Exception:', '').trim(),
      );
    } finally {
      isPlacingOrder.value = false;
    }
  }

  void clearDiscount() {
    discount.value = 0;
    voucher.value = '';
    usedCoins.value = 0;
  }

  void proceedToStripe() {
    Get.snackbar("Stripe", "Redirecting to payment...");
  }

  void onGoOrders() {
    Get.offNamedUntil(
      AppRoutes.orderList,
      arguments: {'status': 'Pending'},
      (route) => route.settings.name == AppRoutes.home,
    );
  }

  void onGoHome() {
    Get.offAllNamed(AppRoutes.home);
  }

  void _showDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required String buttonText,
    required Color buttonColor,
  }) {
    Get.dialog(
      Center(
        child: Container(
          width: 280.w,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 3),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 60.w),
              SizedBox(height: 10.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF124A89),
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: Colors.grey.shade700,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: Get.back,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 10.h,
                  ),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      transitionCurve: Curves.easeOutBack,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  void _showOrderDialog({
    bool success = true,
    required String title,
    required String message,
  }) {
    final color = success ? Colors.green : Colors.redAccent;
    final glowingColor = success
        ? Colors.green.shade100
        : Colors.redAccent.shade100;
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // 1. Success Icon
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glowing background circle
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: glowingColor.withAlpha(128), // Lighter glow
                    ),
                  ),
                  // Inner solid circle for the checkmark
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                    child: Icon(
                      !success ? Icons.error : Icons.check,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),

                  Positioned(
                    top: -20,
                    left: -20,
                    child: Icon(
                      Icons.star,
                      color: Colors.orange.withOpacity(0.3),
                      size: 12,
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    right: -10,
                    child: Icon(
                      Icons.circle,
                      color: Colors.blue.withOpacity(0.3),
                      size: 10,
                    ),
                  ),
                  Positioned(
                    top: -10,
                    right: -25,
                    child: Icon(
                      Icons.square,
                      color: Colors.green.withOpacity(0.3),
                      size: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // 2. Title: Order Confirmed
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // 3. Subtitle
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),

              if (success) ...[
                // 4. "Go to Orders" Button
                ElevatedButton(
                  onPressed: onGoOrders,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blue.shade700, // Primary action color
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50), // Full width
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Go to Orders'),
                ),
                const SizedBox(height: 15),

                // 5. "Go to Home" Button
                OutlinedButton(
                  onPressed: onGoHome,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                    side: BorderSide(color: Colors.blue.shade700, width: 2),
                    minimumSize: const Size(double.infinity, 50), // Full width
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Go to Home'),
                ),
              ],

              if (!success) ...[
                ElevatedButton(
                  onPressed: Get.back,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50), // Full width
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Try again'),
                ),
                const SizedBox(height: 15),
              ],
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
