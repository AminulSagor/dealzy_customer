import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../my_cart/my_cart_controller.dart';

class OrderConfirmationController extends GetxController {
  final RxList<CartItem> items = <CartItem>[].obs;
  final RxDouble discount = 0.0.obs;
  final RxString voucher = ''.obs;

  // 🔹 New coin-related fields
  final RxInt availableCoins = 200.obs; // Example balance
  final RxInt usedCoins = 0.obs;

  double get subtotal =>
      items.fold(0, (sum, e) => sum + e.price * e.quantity.value);

  double get coinValue => usedCoins.value * 0.1; // each coin worth £0.10
  double get total =>
      (subtotal - discount.value - coinValue).clamp(0, double.infinity);

  @override
  void onInit() {
    super.onInit();
    final argItems = Get.arguments as List<CartItem>?;
    if (argItems != null) items.assignAll(argItems);
  }

  void applyVoucher(String code) {
    if (code.trim().toUpperCase() == "SAVE10") {
      discount.value = subtotal * 0.10;
      _showDialog(
        title: "Congratulations!",
        message: "Voucher applied successfully.\nYou got 10% off!",
        icon: Icons.celebration_rounded,
        iconColor: Colors.orangeAccent,
        buttonText: "Awesome 🎉",
        buttonColor: const Color(0xFF124A89),
      );
    } else {
      discount.value = 0;
      _showDialog(
        title: "Invalid Voucher",
        message: "Please check the code and try again.",
        icon: Icons.error_outline,
        iconColor: Colors.redAccent,
        buttonText: "Try Again",
        buttonColor: Colors.redAccent,
      );
    }
  }

  void useCoins(int amount) {
    if (amount <= 0) return;
    if (amount > availableCoins.value) {
      Get.snackbar("Insufficient Coins", "You only have ${availableCoins.value} coins.");
      return;
    }
    usedCoins.value = amount;
  }

  void clearCoins() => usedCoins.value = 0;

  void proceedToStripe() {
    Get.snackbar("Stripe", "Redirecting to payment...");
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
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 3,
              ),
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
                  padding:
                  EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
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
