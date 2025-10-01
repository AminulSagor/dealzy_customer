import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../combine_model/product_item_model.dart';
import '../widgets/product_card.dart';
import 'store_details_controller.dart';

class StoreDetailsView extends GetView<StoreDetailsController> {
  const StoreDetailsView({super.key});



  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 64,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: c.back,
          tooltip: 'Back',
        ),
        centerTitle: false,

        // 👇 new part
        actions: [
          Obx(() => TextButton.icon(
            onPressed: c.isBlocking.value ? null : c.onBlockSeller,
            icon: c.isBlocking.value
                ? const SizedBox(
                width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.block, color: Colors.redAccent, size: 20),
            label: const Text(
              'Block',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          )),
        ],

      ),



      body: Stack(
        children: [
          // --- Header + info (behind the sheet) ---
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(controller: c),
                const SizedBox(height: 16),
                const Divider(height: 24),
                _InfoList(controller: c),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // --- REAL bottom sheet with grid inside ---
          DraggableScrollableSheet(
            controller: c.sheetCtrl,
            snap: true,
            snapSizes: const [
              StoreDetailsController.collapsedSize,
              StoreDetailsController.expandedSize,
            ],
            initialChildSize: StoreDetailsController.collapsedSize,
            minChildSize: StoreDetailsController.collapsedSize,
            maxChildSize: StoreDetailsController.expandedSize,
            builder: (context, scrollController) {
              return _BottomSheetShell(
                controller: c,
                scrollController: scrollController, // drives the GridView
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------- Header & info ----------

class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final StoreDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        SizedBox(width: 30.w,),
        // avatar
        CircleAvatar(
          radius: 34,
          backgroundColor: Colors.grey.shade100,
          child: (c.store.avatarUrl.isEmpty)
              ? const Icon(Icons.store, color: Colors.black38, size: 28)
              : ClipOval(
            child: Image.network(
              c.store.avatarUrl,
              width: 68, height: 68, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.store, color: Colors.black38, size: 28),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // name + type (category) BESIDE the avatar
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.store.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                c.store.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



class _InfoList extends StatelessWidget {
  const _InfoList({required this.controller});
  final StoreDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(icon: Icons.storefront_rounded, text: c.store.address),
        const SizedBox(height: 10),
        _InfoRow(icon: Icons.phone_rounded, text: c.store.phone),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.schedule_rounded, size: 20, color: Colors.black87),
            const SizedBox(width: 10),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('${c.openLabel12h} ',
                      style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  Text(
                    c.isOpenNow ? '(open) ' : '(close) ',
                    style: TextStyle(
                      fontSize: 14,
                      color: c.isOpenNow ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text('to ', style: TextStyle(fontSize: 14, color: Colors.black87)),
                  Text(c.closeLabel12h,
                      style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  const Text(' (close)',
                      style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ),
      ],
    );
  }
}

// ---------- Bottom sheet shell + grid ----------

class _BottomSheetShell extends StatelessWidget {
  const _BottomSheetShell({
    required this.controller,
    required this.scrollController,
  });

  final StoreDetailsController controller;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: c.togglePanel,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    c.isExpanded.value ? 'Less' : 'View',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    c.isExpanded.value
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.black87,
                  ),
                ],
              )),
            ),
          ),
          SizedBox(height: 8.h,),

          Expanded(
            child: Obx(() {
              final items = c.products;

              // Loading state (first page)
              if (c.isLoading.value && items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // Empty state
              if (!c.isLoading.value && items.isEmpty) {
                return const Center(child: Text('No products found'));
              }

              // Grid + infinite scroll trigger (optional)
              return NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  // When we are close to the bottom, ask controller to load more
                  if (n.metrics.extentAfter < 400 &&
                      !c.isLoadingMore.value &&
                      !c.isLoading.value) {
                    c.loadMore();
                  }
                  return false;
                },
                child: GridView.builder(
                  controller: scrollController, // driven by the DraggableScrollableSheet
                  padding: EdgeInsets.fromLTRB(16, 8, 16, bottom > 0 ? bottom : 12),
                  itemCount: items.length + (c.isLoadingMore.value ? 2 : 0), // space for shimmer/loaders
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.86,
                  ),
                  itemBuilder: (_, i) {
                    // tail loaders while paging
                    if (i >= items.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final p = items[i];
                    return ProductCard<ProductItem>(
                      item: p,
                      title: p.title,
                      image: p.image,
                      price: p.price,
                      offerPrice: p.offerPrice,
                      onOpen: (prod) {
                        // e.g. navigate to details
                      },
                      onAdd: (prod) => c.onAdd(prod),   // <-- this now calls BookmarkService
                      brandColor: StoreDetailsController.blue,
                    );

                  },
                ),
              );
            }),
          ),

        ],
      ),
    );
  }
}

class _ProductCardInSheet extends StatelessWidget {
  const _ProductCardInSheet({
    required this.title,
    required this.price,
    required this.image,
    required this.onAdd,
  });

  final String title;
  final double price;
  final String image;
  final VoidCallback onAdd;

  static const _radius = 14.0;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
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
        borderRadius: BorderRadius.circular(_radius),
        child: Stack(
          children: [
            // product image
            Positioned.fill(
              child: Image.network(image, fit: BoxFit.cover),
            ),

            // solid bottom bar for text + button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: StoreDetailsController.blue.withOpacity(0.65), // solid bar
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '\$${price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onAdd,
                        child: const SizedBox(
                          width: 34,
                          height: 34,
                          child: Icon(
                            Icons.add,
                            size: 20,
                            color: StoreDetailsController.blue,
                          ),
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
    );
  }
}

