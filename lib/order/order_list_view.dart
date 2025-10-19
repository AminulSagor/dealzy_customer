import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'order_list_controller.dart';

class OrderListView extends GetView<OrderListController> {
  const OrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final status = args['status'] ?? 'Orders';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$status Orders",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.4,
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF124A89)),
          );
        }

        if (controller.orders.isEmpty) {
          return const Center(
            child: Text("No orders found."),
          );
        }

        return ListView.separated(
          controller: controller.scrollController,
          padding: EdgeInsets.all(16.w),
          itemCount:
          controller.orders.length + (controller.isLoadingMore.value ? 1 : 0),
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            if (controller.isLoadingMore.value &&
                index == controller.orders.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF124A89),
                  ),
                ),
              );
            }

            final o = controller.orders[index];

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 📸 Image touching 3 corners (TopLeft, BottomLeft, BottomRight)
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.r),
                          bottomLeft: Radius.circular(12.r),
                          bottomRight: Radius.circular(0), // sharp right edge
                        ),
                        child: Image.network(
                          o.image,
                          width: 100.w,
                          height: 100.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12.w),

                      /// Info Section
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Order Code: ${o.orderCode}",
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF124A89),
                                ),
                              ),
                              //SizedBox(height: 4.h),
                              Text(
                                o.status,
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              //SizedBox(height: 4.h),
                              Text(
                                "Amount: £${o.amount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Date: ${o.date.day}/${o.date.month}/${o.date.year}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// 🔹 Elegant Cancel Button Section
                  if (o.canCancel && o.status != 'Delivered')
                    Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.r),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 6.h, horizontal: 10.w),
                          ),
                          icon: const Icon(Icons.cancel_outlined,
                              color: Colors.redAccent, size: 18),
                          label: Text(
                            "Cancel Order",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r)),
                                title: const Text("Cancel Order"),
                                content: Text(
                                  "Are you sure you want to cancel order ${o.orderCode}?",
                                  style: TextStyle(fontSize: 13.5.sp),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: Get.back,
                                    child: const Text("No"),
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                    ),
                                    icon: const Icon(Icons.delete_forever,
                                        size: 16, color: Colors.white),
                                    label: const Text(
                                      "Yes, Cancel",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      Get.back();
                                      controller.cancelOrder(o);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
