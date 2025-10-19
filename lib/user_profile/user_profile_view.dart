import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dealzy/widgets/app_bottom_nav.dart';
import '../routes/app_routes.dart';
import 'user_profile_controller.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar (Settings on right)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Spacer(),
                  InkWell(
                    onTap: c.openSettings,
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: const [
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.settings, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Avatar + camera badge
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  const double size = 108;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: size / 2,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            (c.avatar.value.isNotEmpty &&
                                c.avatar.value.startsWith('http'))
                            ? NetworkImage(c.avatar.value)
                            : null,
                        child:
                            (c.avatar.value.isEmpty ||
                                !c.avatar.value.startsWith('http'))
                            ? const Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 32,
                              )
                            : null,
                      ),

                      // uploading dim + spinner
                      if (c.isUploadingAvatar.value)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // camera badge
                      Positioned(
                        right: 12,
                        bottom: -7,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Material(
                            color: const Color(0xFF124A89),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: c.isUploadingAvatar.value
                                  ? null
                                  : c.changeAvatar,
                              child: const SizedBox(
                                width: 24,
                                height: 24,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),

            const SizedBox(height: 8),
            Obx(
              () => Text(
                c.name.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Obx(
              () => Text(
                c.location.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),

            // Collection
            const SizedBox(height: 12),

            /// ✅ Available Coins Section
            Obx(
              () => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF124A89),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Available Coins",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    Text(
                      "${controller.coins.value}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// ✅ Order Status Section
            /// ✅ Order Status Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "My Orders",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: controller.orders.map((o) {
                      return Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Get.toNamed(
                            AppRoutes.orderList, // ✅ your new route
                            arguments: {'status': o.label}, // pass which tab to show
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 45,
                                width: 45,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF004EB5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.asset(o.image, fit: BoxFit.contain),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                o.label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )),
                ],
              ),
            ),


            const SizedBox(height: 14),
            const Divider(height: 1),

            // ✅ Continue your Collection section as before
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  // 🔹 Show loading indicator
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF124A89)),
                  );
                }

                if (c.error.value != null) {
                  // 🔹 Show error message (optional)
                  return Center(
                    child: Text(
                      'Error: ${c.error.value}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (c.collection.isEmpty) {
                  // 🔹 Empty state
                  return const Center(
                    child: Text(
                      'You do not have any bookmarked items.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                // 🔹 Main list
                final showFooter = c.isLoadingMore.value;
                final count = c.collection.length + (showFooter ? 1 : 0);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                  children: [
                    const Text(
                      'Collection',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        controller: c.collectionCtrl,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(right: 16),
                        itemCount: count,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (_, i) {
                          if (showFooter && i == count - 1) {
                            return const SizedBox(
                              width: 165,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          }

                          final item = c.collection[i];
                          return _CollectionCard(
                            item: item,
                            onOpen: c.openProduct,
                            onRemove: c.removeFromCollection,
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),

          ],
        ),
      ),

      // Bottom nav: user tab selected (index 3)
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.item,
    required this.onOpen,
    required this.onRemove,
  });

  final ProductItem item;
  final void Function(ProductItem) onOpen;
  final void Function(ProductItem) onRemove;

  static const _bandColor = Color(0xFF124A89); // brand blue

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onOpen(item),
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        width: 165,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // image
              Positioned.fill(
                child: item.image.startsWith('http')
                    ? Image.network(item.image, fit: BoxFit.cover)
                    : Image.asset(item.image, fit: BoxFit.cover),
              ),

              // bottom blue band (text background)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 54, // adjust 60–84 to taste
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: _bandColor.withOpacity(0.70),
                  ),
                  child: Row(
                    children: [
                      // title + price
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\£${item.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // remove button (doesn't trigger parent tap)
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => onRemove(item),
                          child: const SizedBox(
                            width: 34,
                            height: 34,
                            child: Icon(Icons.remove, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
