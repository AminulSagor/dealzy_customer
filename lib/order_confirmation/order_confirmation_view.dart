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
        title: Text("Order Confirmation",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
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
                            child: Image.asset(item.imageUrl,
                                width: 50.w, height: 50.w, fit: BoxFit.cover),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName,
                                    style: TextStyle(
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w600)),
                                Text("${item.quantity.value} × £${item.price}",
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          Text(
                            "£${(item.price * item.quantity.value).toStringAsFixed(0)}",
                            style: TextStyle(
                                fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),

            /// Voucher Section
            Padding(
              padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => controller.voucher.value = v,
                      decoration: InputDecoration(
                        hintText: "Enter voucher code",
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: () =>
                        controller.applyVoucher(controller.voucher.value),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF124A89),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                      padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    ),
                    child: Text("Apply",
                        style:
                        TextStyle(fontSize: 13.sp, color: Colors.white)),
                  ),
                ],
              ),
            ),

            /// 🔹 Coin Usage Section
            Obx(() => Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.grey.shade50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Your Coins: ${controller.availableCoins.value}",
                      style: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: coinController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Enter coins to use",
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      ElevatedButton(
                        onPressed: () {
                          final entered = int.tryParse(coinController.text);
                          if (entered != null) {
                            controller.useCoins(entered);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                        ),
                        child: Text("Use Coins",
                            style: TextStyle(
                                fontSize: 13.sp, color: Colors.white)),
                      ),
                    ],
                  ),
                  if (controller.usedCoins.value > 0) ...[
                    SizedBox(height: 5.h),
                    Text(
                      "Using ${controller.usedCoins.value} coins (-£${controller.coinValue.toStringAsFixed(2)})",
                      style: TextStyle(
                          fontSize: 12.5.sp, color: Colors.green.shade700),
                    ),
                  ],
                ],
              ),
            )),

            /// Summary
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _priceRow("Subtotal", controller.subtotal),
                _priceRow("Discount", -controller.discount.value),
                _priceRow("Coins Used", -controller.coinValue),
                const Divider(),
                _priceRow("Total", controller.total, bold: true),
                SizedBox(height: 12.h),

                /// Proceed Button
                ElevatedButton(
                  onPressed: controller.proceedToStripe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF124A89),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    "Proceed to Pay £${controller.total.toStringAsFixed(2)}",
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
          Text(
            (value < 0
                ? "-£${value.abs().toStringAsFixed(2)}"
                : "£${value.toStringAsFixed(2)}"),
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
