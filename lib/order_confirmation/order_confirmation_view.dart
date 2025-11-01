import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'order_confirmation_controller.dart';

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
            Obx(() {
              final availableCoins = controller.availableCoins.value;
              final minimumUse = controller.minimumUse.value;
              final isValidCoins = availableCoins > minimumUse;
              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Voucher",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    8.h.verticalSpace,
                    TextField(
                      onChanged: (v) => controller.voucher.value = v,
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
                    if (isValidCoins) ...[
                      10.h.verticalSpace,
                      Text(
                        "Your Available Coins: $availableCoins",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      TextField(
                        enabled: isValidCoins,
                        onChanged: (v) => controller.coin.value = v,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter coins to use",
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
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
                    12.h.verticalSpace,
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            controller.isApplying.value ||
                                controller.voucher.value.isEmpty &&
                                    controller.coin.value.isEmpty
                            ? null
                            : () {
                                final coinToUse = int.tryParse(
                                  controller.coin.value,
                                );
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
                        child: Text(
                          controller.isApplying.value
                              ? 'Please wait...'
                              : "Apply",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

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

                  10.h.verticalSpace,

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
                  const Text(
                    'Payment Confirmation',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey[300]),
                  SizedBox(height: 10),
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '£$amountToPay',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Send message to seller (optional)",
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              const SizedBox(height: 8),

              // 2. Online Payment Option
              ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: Text('Pay Now'),
                onPressed: () => controller.proceedToStripe(
                  amount: (controller.total * 100).toInt().toString(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // const SizedBox(height: 12),

              // // 3. Alternative/Other Payment Option
              // OutlinedButton.icon(
              //   icon: const Icon(Icons.access_time),
              //   label: const Text('Pay Later'),
              //   onPressed: () {
              //     Get.back();
              //     controller.onConfirmOrder();
              //   },
              //   style: OutlinedButton.styleFrom(
              //     foregroundColor: Colors.blue.shade700,
              //     side: BorderSide(color: Colors.blue.shade700),
              //     padding: const EdgeInsets.symmetric(vertical: 16),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
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
