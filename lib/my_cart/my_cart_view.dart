import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../widgets/app_bottom_nav.dart';
import 'get_carts_service.dart';
import 'my_cart_controller.dart';

class MyCartView extends GetView<MyCartController> {
  const MyCartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "My Cart",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
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
                  final selectedItems = controller.items
                      .where((e) => e.isSelected.value)
                      .toList();
                  Get.toNamed(
                    AppRoutes.orderConfirmation,
                    arguments: {
                      'items': selectedItems,
                      'coinData': controller.coinData,
                    },
                  );
                }
              : null,
          backgroundColor: isActive
              ? const Color(0xFF124A89)
              : Colors.grey.shade400,
          label: Text(
            isActive ? "Checkout ($selectedCount)" : "Checkout",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final items = controller.items;
        final seller = controller.seller.value;

        return Stack(
          children: [
            if (seller != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔹 Product Group
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(10.r),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(10.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Store Header
                            Row(
                              children: [
                                Checkbox(
                                  value: items.every((e) => e.isSelected.value),
                                  onChanged: (val) =>
                                      controller.toggleSelectAll(val),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                const Icon(
                                  Icons.storefront,
                                  size: 18,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    seller.storeName,
                                    style: TextStyle(
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: controller.selectedCount < 1
                                        ? Colors.grey
                                        : Colors.redAccent,
                                  ),
                                  onPressed: controller.selectedCount < 1
                                      ? null
                                      : controller.bulkDelete,
                                  tooltip: "Delete selected items",
                                ),
                              ],
                            ),

                            SizedBox(height: 8.h),

                            /// Cart Items
                            Expanded(
                              child: ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context, i) {
                                  final item = items[i];
                                  return Dismissible(
                                    key: ValueKey(item),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onDismissed: (_) =>
                                        controller.removeItem(item),
                                    child: _CartTile(
                                      item: item,
                                      controller: controller,
                                      itemIndex: i,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            /// 🔄 Loading overlay
            if (isLoading) _loader(),

            if (!isLoading && seller == null)
              Center(
                child: Text(
                  'Cart is empty',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

Widget _loader({double? width, double? height}) {
  return Container(
    color: Colors.white.withOpacity(0.7),
    child: Center(
      child: SizedBox(
        width: width ?? 45.w,
        height: height ?? 45.w,
        child: const CircularProgressIndicator(
          color: Color(0xFF124A89),
          strokeWidth: 3,
        ),
      ),
    ),
  );
}

/// 🔹 Cart Tile Widget
class _CartTile extends StatelessWidget {
  final CartItem item;
  final MyCartController controller;
  final int itemIndex;

  const _CartTile({
    required this.item,
    required this.controller,
    required this.itemIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: Colors.grey.shade50,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Checkbox
            Checkbox(
              value: item.isSelected.value,
              onChanged: item.isAvailable
                  ? (_) => controller.toggleItem(item)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),

            /// Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Image.network(
                item.imagePath,
                width: 60.w,
                height: 60.w,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10.w),

            /// Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  if (item.brand != null && item.brand != '')
                    Text(
                      'Brand: ${item.brand!}',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),

                  /// 🔹 Color & Variant Selection Row
                  GestureDetector(
                    onTap: () => _showColorVariantSheet(
                      item: item,
                      itemIndex: itemIndex,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Available options',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        4.w.horizontalSpace,
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),

                  /// Price
                  Text(
                    "\£${item.price.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            /// Quantity Controls + Availability
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
                      child: Text(
                        "${item.quantity.value}",
                        style: TextStyle(fontSize: 12.sp),
                      ),
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
      );
    });
  }

  /// 🔹 Bottom Sheet for Color & Variant selection
  void _showColorVariantSheet({
    required CartItem item,
    required int itemIndex,
  }) {
    controller.fetchColorsAndVariants(item.productId, itemIndex);
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Obx(() {
            final isOptionsLoading = controller.isOptionsLoading.value;
            final isNoOptions =
                !isOptionsLoading &&
                item.selectedColor.value == null &&
                item.selectedVariant.value == null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Row(
                  children: [
                    /// Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: Image.network(
                        item.imagePath,
                        width: 60.w,
                        height: 60.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 10.w),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        if (item.brand != null && item.brand != '')
                          Text(
                            item.brand!,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),

                        /// Price
                        Text(
                          "\£${item.price.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                20.h.verticalSpace,
                Text(
                  "Choose Options",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 14.h),

                if (controller.isOptionsLoading.value) ...[
                  _loader(width: 30.w, height: 30.w),
                ],

                if (isNoOptions)
                  Center(
                    child: Text(
                      '--- No color and variant options available ---',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                /// 🔹 Color Selection
                if (item.colors.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Color",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Obx(() {
                        return Wrap(
                          spacing: 8,
                          children: item.colors.map((c) {
                            final isSelected =
                                item.selectedColor.value?.id == c.id;
                            return ChoiceChip(
                              label: Text(c.color),
                              selected: isSelected,
                              onSelected: (_) => item.selectedColor.value = c,
                              selectedColor: Colors.blue.shade100,
                            );
                          }).toList(),
                        );
                      }),
                      SizedBox(height: 14.h),
                    ],
                  ),

                /// 🔹 Variant Selection
                if (item.variants.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Variant",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Obx(() {
                        return Wrap(
                          spacing: 8,
                          children: item.variants.map((v) {
                            final isSelected =
                                item.selectedVariant.value?.id == v.id;
                            return ChoiceChip(
                              label: Text(v.variant),
                              selected: isSelected,
                              onSelected: (_) => item.selectedVariant.value = v,
                              selectedColor: Colors.green.shade100,
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),

                SizedBox(height: 24.h),

                if (!isOptionsLoading && !isNoOptions)
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF124A89),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 10.h,
                        ),
                        child: Text(
                          "Apply",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
