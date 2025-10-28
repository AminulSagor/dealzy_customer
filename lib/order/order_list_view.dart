import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'get_customer_orders_service.dart';
import 'order_list_controller.dart';

class OrderListView extends GetView<OrderListController> {
  const OrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    final status = controller.status;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${status.capitalizeFirst} Orders",
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

        if (controller.sellers.isEmpty) {
          return const Center(child: Text("No orders found."));
        }

        return ListView.builder(
          controller: controller.scrollController,
          padding: EdgeInsets.all(16.w),
          itemCount:
              controller.sellers.length +
              (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (controller.isLoadingMore.value &&
                index == controller.sellers.length) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF124A89),
                  ),
                ),
              );
            }

            final seller = controller.sellers[index];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seller Header
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12.r,
                        backgroundImage: NetworkImage(seller.profilePath),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          seller.storeName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🧾 Orders List under this seller
                ...seller.orders.map(
                  (order) => Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.black12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Header with “Show Code”
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order #${order.orderId}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            if (order.status.toLowerCase() != 'pending')
                              Obx(() {
                                final isLoadingCode = controller.loadingCodes
                                    .contains(order.orderId);
                                final code =
                                    controller.orderCodes[order.orderId];

                                return TextButton.icon(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 2.h,
                                    ),
                                    backgroundColor: Colors.blue.shade700
                                        .withAlpha(20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.confirmation_number_outlined,
                                    size: 16,
                                    color: Colors.blue.shade800,
                                  ),
                                  label: isLoadingCode
                                      ? SizedBox(
                                          width: 16.w,
                                          height: 16.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.blue.shade800,
                                          ),
                                        )
                                      : Text(
                                          code == null
                                              ? "Show Code"
                                              : "Code: $code",
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: Colors.blue.shade800,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                  onPressed: code != null
                                      ? null
                                      : () => controller.generateOrderCode(
                                          order.orderId,
                                        ),
                                );
                              }),

                            if (order.status.toLowerCase() == 'pending')
                              Align(
                                alignment: Alignment.centerRight,
                                child: Obx(() {
                                  final isCancelling = controller
                                      .cancellingOrders
                                      .contains(order.orderId);

                                  return OutlinedButton.icon(
                                    onPressed: isCancelling
                                        ? null
                                        : () {
                                            _showConfirmationDialog(
                                              controller: controller,
                                              order: order,
                                            );
                                          },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Colors.redAccent,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                      ),
                                    ),
                                    icon: isCancelling
                                        ? SizedBox(
                                            width: 14.w,
                                            height: 14.w,
                                            child:
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.redAccent,
                                                ),
                                          )
                                        : const Icon(
                                            Icons.cancel_outlined,
                                            color: Colors.redAccent,
                                            size: 14,
                                          ),
                                    label: Text(
                                      isCancelling
                                          ? "Cancelling..."
                                          : "Cancel Order",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        // Items
                        Column(children: order.items.map(_itemCard).toList()),
                        6.h.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Total: ",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black45,
                              ),
                            ),
                            Text(
                              "£ ${order.subtotal.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}

Widget _itemCard(OrderedItem item) {
  return Container(
    margin: EdgeInsets.only(bottom: 10.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.network(
            item.imagePath,
            width: 70.w,
            height: 70.w,
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
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 2.h),
              if (item.brand.isNotEmpty)
                Text(
                  "Brand: ${item.brand.isEmpty ? 'N/A' : item.brand}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              if (item.color.isNotEmpty || item.variant.isNotEmpty)
                Text(
                  "Color: ${item.color}, Variant: ${item.variant}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              2.h.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Qty: ${item.quantity}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "£ ${(item.quantity * item.rate).toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void _showConfirmationDialog({
  required OrderListController controller,
  required Order order,
}) {
  Get.dialog(
    AlertDialog(
      title: const Text("Cancel Order"),
      content: Text("Are you sure you want to cancel Order #${order.orderId}?"),
      actions: [
        TextButton(onPressed: Get.back, child: const Text("No")),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
          icon: const Icon(Icons.delete_forever, color: Colors.white, size: 16),
          label: const Text(
            "Yes, Cancel",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Get.back();
            controller.cancelOrder(order.orderId);
          },
        ),
      ],
    ),
  );
}
