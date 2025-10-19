import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../widgets/app_bottom_nav.dart';
import 'my_cart_controller.dart';

class MyCartView extends GetView<MyCartController> {
  const MyCartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("My Cart",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.4,
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),

      /// Floating checkout button
      floatingActionButton: Obx(() {
        final selectedCount = controller.selectedCount;
        final isActive = selectedCount > 0;
        return FloatingActionButton.extended(
          onPressed: isActive
              ? () {
            final selectedItems = controller.items.where((e) => e.isSelected.value).toList();
            Get.toNamed(AppRoutes.orderConfirmation, arguments: selectedItems);
          }
              : null,

          backgroundColor:
          isActive ? const Color(0xFF124A89) : Colors.grey.shade400,
          label: Text(
            isActive ? "Checkout ($selectedCount)" : "Checkout",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
         // icon: const Icon(Icons.shopping_cart_checkout),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Obx(() {
        final isLoading = controller.isLoading.value;

        return Stack(
          children: [
            /// 🛒 Main content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 Select All + Bulk Delete
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text("Select all", style: TextStyle(fontSize: 13.sp)),
                          Checkbox(
                            value: controller.selectAll.value,
                            onChanged: controller.toggleSelectAll,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                        onPressed: controller.bulkDelete,
                        tooltip: "Delete selected items",
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  /// 🔹 Product Groups
                  Expanded(
                    child: ListView.separated(
                      controller: controller.scrollController,
                      itemCount: controller.groupedItems.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (_, g) {
                        final group = controller.groupedItems[g];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(10.r),
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(10.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// 🔹 Store Header
                              Row(
                                children: [
                                  Checkbox(
                                    value: group.items
                                        .every((e) => e.isSelected.value),
                                    onChanged: (val) => controller
                                        .toggleStoreSelection(group.storeId, val),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  const Icon(Icons.storefront,
                                      size: 18, color: Colors.black54),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      group.storeName,
                                      style: TextStyle(
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 8.h),

                              /// 🔹 Store Items with Swipe to Delete
                              Column(
                                children: group.items
                                    .map((item) => Dismissible(
                                  key: ValueKey(item),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius:
                                      BorderRadius.circular(8.r),
                                    ),
                                    child: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                  onDismissed: (_) =>
                                      controller.removeItem(item),
                                  child: _CartTile(
                                      item: item, controller: controller),
                                ))
                                    .toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            /// 🔄 Loading overlay
            if (isLoading)
              Container(
                color: Colors.white.withOpacity(0.7),
                child: Center(
                  child: SizedBox(
                    width: 45.w,
                    height: 45.w,
                    child: const CircularProgressIndicator(
                      color: Color(0xFF124A89),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),

    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  final MyCartController controller;

  const _CartTile({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.grey.shade50,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 🔹 Checkbox
          Checkbox(
            value: item.isSelected.value,
            onChanged: (_) => controller.toggleItem(item),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),

          /// 🔹 Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Image.asset(
              item.imageUrl,
              width: 60.w,
              height: 60.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10.w),

          /// 🔹 Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                Text(item.brandName,
                    style: TextStyle(
                        fontSize: 11.5.sp,
                        color: Colors.grey.shade600)),
                Text("\£${item.price.toStringAsFixed(0)}",
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          /// 🔹 Quantity Controls + Availability
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => controller.decreaseQuantity(item),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: const Icon(Icons.remove, size: 14),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Text("${item.quantity.value}",
                        style: TextStyle(fontSize: 12.sp)),
                  ),
                  InkWell(
                    onTap: () => controller.increaseQuantity(item),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: const Icon(Icons.add, size: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                item.isAvailable ? "Available" : "Out of stock",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: item.isAvailable ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
