import 'package:dealzy/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../my_cart/get_carts_service.dart';
import 'get_discount_service.dart';

class OrderConfirmationController extends GetxController {
  final RxList<CartItem> items = <CartItem>[].obs;
  final RxDouble discount = 0.0.obs;
  final RxString voucher = ''.obs;

  // 🔹 Coin-related fields
  final RxInt availableCoins = 0.obs;
  final RxInt minimumUse = 0.obs;
  final RxInt usedCoins = 0.obs;

  // 🔹 Loading state for API call
  final RxBool isApplying = false.obs;

  final _discountService = GetDiscountService();

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
    discount.value = 0; // reset before call

    try {
      final res = await _discountService.estimateDiscount(
        subTotal: subtotal,
        coupon: voucherCode,
        coins: coinsToUse,
      );

      if (res.isSuccess) {
        // ✅ Update discount
        discount.value = res.discount;

        // ✅ Save states
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
      } else {
        _showDialog(
          title: "No Discount",
          message: res.message.isNotEmpty
              ? res.message
              : "No valid coupon or coins applied.",
          icon: Icons.info_outline,
          iconColor: Colors.orange,
          buttonText: "OK",
          buttonColor: Colors.orange,
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

  void onConfirmOrder() {
    // TODO: connect to backend order confirmation
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
}
