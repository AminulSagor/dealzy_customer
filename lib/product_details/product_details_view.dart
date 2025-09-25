import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'product_details_controller.dart';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Reactive body: loading → spinner, error → message, data → content
          Obx(() {
            if (c.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (c.error.value != null) {
              return _ErrorState(
                message: c.error.value!,
                onRetry: () => c.onInit(), // simple retry
              );
            }

            // Main scroll when data present
            return ListView(
              padding: EdgeInsets.only(
                bottom: 100 + MediaQuery.of(context).padding.bottom,
              ),
              children: [
                // 1) Full-bleed image (touches top/left/right)
                _HeroImage(controller: c),

                // 2) Curved white body that "carves" into the image
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: _CurvedBody(controller: c),
                ),
              ],
            );
          }),

          // Floating back button over the image
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: Material(
              shape: const CircleBorder(),
              color: Colors.black.withOpacity(0.5),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: Get.back,
                tooltip: 'Back',
              ),
            ),
          ),

          // Floating Bookmark button
          Positioned(
            left: 0,
            right: 0,
            bottom: 14 + MediaQuery.of(context).padding.bottom,
            child: Center(
              child: // In ProductDetailsView, where the "Bookmark" button is:
              Obx(() {
                final busy = c.isBookmarking.value;
                return ElevatedButton(
                  onPressed: busy ? null : c.onBookmark, // disabled when busy
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF124A89),
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(.18),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: const BorderSide(color: Colors.black12),
                    ),
                  ),
                  child: Text(
                    busy ? 'Saving...' : 'Bookmark',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-bleed hero image (handles empty/fallback safely)
class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.controller});
  final ProductDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final images = c.product.images;
    return AspectRatio(
      aspectRatio: 1,
      child: (images.isEmpty)
          ? Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_rounded, size: 48, color: Colors.grey),
      )
          : PageView.builder(
        controller: c.pageCtrl,
        itemCount: images.length,
        itemBuilder: (_, i) => Image.network(
          images[i],
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// White curved body that contains dots + all content
class _CurvedBody extends StatelessWidget {
  const _CurvedBody({required this.controller});
  final ProductDetailsController controller;

  static const double _pad = 16.0;

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_pad, 12, _pad, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dots on white background (explicit Rx read)
            Center(
              child: Obx(() {
                final page = c.currentPage.value;          // <-- Rx read
                final total = c.product.images.length;     // non-Rx is fine
                if (total <= 1) return const SizedBox(height: 20);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    total,
                        (i) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (page == i)
                            ? const Color(0xFF124A89)
                            : Colors.blueGrey.withOpacity(.35),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),

            // Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    c.product.title,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.5,
                      color: Colors.black87,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Price row — dynamic (shows strike-through only if discounted)
            _PriceRow(controller: c),

            const SizedBox(height: 12),

            // Specs
            _SpecRow(label: 'Brand', value: c.product.brand),
            _SpecRow(label: 'Model', value: c.product.model),
            _SpecRow(label: 'Color', value: c.product.color),
            _SpecRow(label: 'Size', value: c.product.sizeText),
            _SpecRow(label: 'Category', value: c.product.category),
            _SpecRow(label: 'Availability', value: c.product.availabilityText),
            const SizedBox(height: 10),

            // Description (explicit Rx read)
            Obx(() => _ExpandableText(
              text: c.product.description,
              expanded: c.descExpanded.value, // <-- Rx read
              onToggle: c.toggleDesc,
            )),
            const SizedBox(height: 18),

            // Shop Details
            const Text(
              'Shop Details',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _ShopDetails(controller: c),
            const SizedBox(height: 18),



          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.controller});
  final ProductDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final p = controller.product;
    final hasDiscount = p.offerPrice < p.mrp;

    if (hasDiscount) {
      return Row(
        children: [
          Text(
            '\£${p.mrp.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.black45,
              decoration: TextDecoration.lineThrough,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '\£${p.offerPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          const Text('(offer)', style: TextStyle(color: Colors.black54)),
        ],
      );
    }

    // No discount → single price, no strike-through
    return Text(
      '\$${p.mrp.toStringAsFixed(0)}',
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label : ',
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(color: Colors.black87, height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableText extends StatelessWidget {
  const _ExpandableText({
    required this.text,
    required this.expanded,
    required this.onToggle,
    this.trimLines = 3,
  });

  final String text;
  final bool expanded;
  final VoidCallback onToggle;
  final int trimLines;

  @override
  Widget build(BuildContext context) {
    final showToggle = text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          textAlign: TextAlign.left,
          maxLines: expanded ? null : trimLines,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black87, height: 1.35),
        ),
        if (showToggle) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onToggle,
            child: Text(
              expanded ? 'see less' : 'see more',
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.black54,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ShopDetails extends StatelessWidget {
  const _ShopDetails({required this.controller});
  final ProductDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?q=80&w=800&auto=format&fit=crop',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      c.store.name,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      c.store.category,
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),

            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.storefront_rounded, size: 18, color: Colors.black87),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  c.store.address,
                  textAlign: TextAlign.left,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.phone_rounded, size: 18, color: Colors.black87),
              const SizedBox(width: 6),
              Text(
                c.store.phone,
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 18, color: Colors.black87),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('${c.openLabel12h} ',
                        style: const TextStyle(color: Colors.black87)),
                    Text(
                      c.isOpenNow ? '(open) ' : '(close) ',
                      style: TextStyle(
                        color: c.isOpenNow ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text('to ', style: TextStyle(color: Colors.black87)),
                    Text(c.closeLabel12h,
                        style: const TextStyle(color: Colors.black87)),
                    const Text(
                      ' (close)',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
