import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dealzy/widgets/app_bottom_nav.dart';
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
                        Text('Settings',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
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
                        backgroundImage: c.avatar.value.startsWith('http')
                            ? NetworkImage(c.avatar.value)
                            : AssetImage(c.avatar.value) as ImageProvider,
                      ),
                      Positioned(
                        right: 12,
                        bottom: -7,
                        child: Container(
                          padding: const EdgeInsets.all(3), // ring thickness
                          decoration: const BoxDecoration(
                            color: Colors.white,            // ring color
                            shape: BoxShape.circle,
                          ),
                          child: Material(
                            color: const Color(0xFF124A89),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: c.changeAvatar,
                              child: const SizedBox(
                                width: 24,
                                height: 24,
                                child: Icon(Icons.camera_alt, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ),
                      )

                    ],
                  );
                }),
              ],
            ),

            const SizedBox(height: 8),
            Obx(() => Text(
              c.name.value,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500),
            )),
            const SizedBox(height: 2),
            Obx(() => Text(
              c.location.value,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700),
            )),
            const SizedBox(height: 12),
            const Divider(height: 1),

            // Collection
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                children: [
                  const Text(
                    'Collection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 16),
                      itemCount: c.collection.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (_, i) => _CollectionCard(
                        item: c.collection[i],
                        onOpen: c.openProduct,
                        onRemove: c.removeFromCollection,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom nav: user tab selected (index 3)
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
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
                              '\$${item.price.toStringAsFixed(0)}',
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
