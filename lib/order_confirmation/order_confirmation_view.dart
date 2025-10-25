import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'order_confirmation_controller.dart';
import '../my_cart/my_cart_controller.dart';

class OrderConfirmationView extends GetView<OrderConfirmationController> {
  const OrderConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController coinController = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Order Confirmation",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.4,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Selected Items
            Expanded(
              child: Obx(() {
                final items = controller.items;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10.r),
                        color: Colors.grey.shade50,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: Image.network(
                              item.imagePath,
                              width: 50.w,
                              height: 50.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "${item.quantity.value} × £${item.price}",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "£${(item.price * item.quantity.value).toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),

            /// 🔹 Voucher Section & Coin Usage Section
            Obx(
              () => Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Voucher",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          8.h.verticalSpace,
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (v) =>
                                      controller.voucher.value = v,
                                  decoration: InputDecoration(
                                    hintText: "Enter voucher code",
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 10.h,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                ),
                              ),

                              // ElevatedButton(
                              //   onPressed: () =>
                              //       controller.applyVoucher(controller.voucher.value),
                              //   style: ElevatedButton.styleFrom(
                              //     backgroundColor: const Color(0xFF124A89),
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(8.r),
                              //     ),
                              //     padding: EdgeInsets.symmetric(
                              //       horizontal: 16.w,
                              //       vertical: 12.h,
                              //     ),
                              //   ),
                              //   child: Text(
                              //     "Apply",
                              //     style: TextStyle(fontSize: 13.sp, color: Colors.white),
                              //   ),
                              // ),
                            ],
                          ),
                          if (controller.availableCoins.value > 0 &&
                              controller.availableCoins.value >
                                  controller.minimumUse.value) ...[
                            10.h.verticalSpace,
                            Text(
                              "Your Available Coins: ${controller.availableCoins.value}",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    enabled:
                                        controller.availableCoins.value > 0,
                                    controller: coinController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "Enter coins to use",
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 6.h,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // ElevatedButton(
                                //   onPressed: () {
                                //     final entered = int.tryParse(coinController.text);
                                //     if (entered != null) {
                                //       controller.useCoins(entered);
                                //     }
                                //   },
                                //   style: ElevatedButton.styleFrom(
                                //     backgroundColor: Colors.amber.shade700,
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(8.r),
                                //     ),
                                //     padding: EdgeInsets.symmetric(
                                //       horizontal: 16.w,
                                //       vertical: 12.h,
                                //     ),
                                //   ),
                                //   child: Text(
                                //     "Use Coins",
                                //     style: TextStyle(
                                //       fontSize: 13.sp,
                                //       color: Colors.white,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                            if (controller.usedCoins.value > 0) ...[
                              SizedBox(height: 5.h),
                              Text(
                                "Using ${controller.usedCoins.value} coins",
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                    20.w.horizontalSpace,
                    ElevatedButton(
                      onPressed: () {
                        final coinToUse = int.tryParse(coinController.text);
                        controller.applyDiscount(
                          voucherCode: controller.voucher.value,
                          coinsToUse: coinToUse,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF124A89),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 25.w,
                          vertical: 12.h,
                        ),
                      ),
                      child: controller.isApplying.value
                          ? CircularProgressIndicator()
                          : Text(
                              "Apply",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            /// Summary
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _priceRow("Subtotal", controller.subtotal),
                  _priceRow("Discount", -controller.discount.value),
                  // _priceRow("Coins Used", -controller.coinValue),
                  const Divider(),
                  _priceRow("Total", controller.total, bold: true),
                  SizedBox(height: 12.h),

                  /// Proceed Button
                  ElevatedButton(
                    onPressed: showPaymentOptionsBottomSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF124A89),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      "Confirm Order",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showPaymentOptionsBottomSheet() {
    final amountToPay = controller.total.toStringAsFixed(2);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(
          top: 24,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Keep the sheet compact
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Do you want to pay online?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey[300]),
                  SizedBox(height: 10),
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '£$amountToPay',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              const SizedBox(height: 8),

              // 2. Online Payment Option
              ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text('Yes, Pay Online Now'),
                onPressed: controller.proceedToStripe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 3. Alternative/Other Payment Option
              OutlinedButton.icon(
                icon: const Icon(Icons.access_time),
                label: const Text('No, Pay Later'),
                onPressed: () {
                  Get.back();
                  showOrderConfirmedDialog();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  side: BorderSide(color: Colors.blue.shade700),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  void showOrderConfirmedDialog() {
    Get.dialog(
      // Use an AlertDialog for basic structure, then customize its content
      AlertDialog(
        contentPadding:
            EdgeInsets.zero, // Important to control padding ourselves
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            20,
          ), // Rounded corners for the dialog
        ),
        backgroundColor: Colors.white, // Adapts to theme
        content: Container(
          // Padding for the inner content
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make column wrap its children
            children: <Widget>[
              // 1. Success Icon (inspired by the image)
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glowing background circle
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.shade100.withOpacity(
                        0.5,
                      ), // Lighter glow
                    ),
                  ),
                  // Inner solid circle for the checkmark
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green, // Main orange color
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  // Optional: A subtle "confetti" like effect visually if not animating
                  // For actual confetti, you'd use a package or a custom painter
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
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // 3. Subtitle
              Text(
                'Your order has been placed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),

              // 4. "Go to Orders" Button
              ElevatedButton(
                onPressed: controller.onGoOrders,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700, // Primary action color
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
                onPressed: controller.onGoHome,
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
          ),
        ),
      ),
      barrierDismissible:
          false, // User must choose an action, cannot tap outside
    );
  }

  Widget _priceRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            (value < 0
                ? "-£${value.abs().toStringAsFixed(2)}"
                : "£${value.toStringAsFixed(2)}"),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
