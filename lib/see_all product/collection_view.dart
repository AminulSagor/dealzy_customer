import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/product_card.dart';
// import '../widgets/search_bar.dart'; // ❌ removed
import 'collection_controller.dart';

class CollectionView extends GetView<CollectionController> {
  const CollectionView({super.key});

  static const _blue = Color(0xFF124A89);

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Obx(() {
      final isFromHome = c.fromHomeRx.value;

      return Scaffold(
        backgroundColor: Colors.white,

        // ✅ either a real AppBar or null
        appBar: isFromHome
            ? null
            : AppBar(
                backgroundColor: Colors.white,
                elevation: 0.5,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: c.back,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: Colors.black87,
                  ),
                  tooltip: 'Back',
                ),
                title: Text(
                  // 1) Category name has highest priority
                  c.categoryName?.isNotEmpty == true
                      ? c.categoryName!
                      // 2) Otherwise show the title you passed from Home (Regular Offer, Expiring Offer, Clearance Offer)
                      : (c.screenTitle.isNotEmpty
                            ? c.screenTitle
                            // 3) Fallback
                            : 'Collections'),
                  style: const TextStyle(color: Colors.black87),
                ),
              ),

        body: Column(
          children: [
            // ✅ show search bar on top only when fromHome
            // ✅ show back + search in one row when fromHome
            if (isFromHome)
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Row(
                    children: [
                      _ToolbarBackButton(onPressed: c.back),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CollectionSearchField(
                          controller: c.searchCtrl,
                          hintText: 'Search products',
                          onChanged: c.onSearchChanged,
                          onSubmitted: c.onSearchSubmitted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // rest stays the same
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => c.fetchFirstPage(limit: c.pageSize.value),
                child: Obx(() {
                  final loading = c.isLoading.value;
                  final err = c.error.value;
                  final loadingMore = c.isLoadingMore.value;
                  final fromHome = c.fromHome;
                  final hasQuery = c.query.value.trim().isNotEmpty;

                  return CustomScrollView(
                    controller: c.gridCtrl,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (!loading && (c.items.isEmpty))
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 72),
                            child: Column(
                              children: [
                                if (err != null) ...[
                                  _ErrorState(
                                    message: err,
                                    onRetry: () => c.fetchFirstPage(
                                      limit: c.pageSize.value,
                                    ),
                                  ),
                                ] else if (fromHome && !hasQuery) ...[
                                  const Icon(
                                    Icons.search,
                                    size: 48,
                                    color: Colors.black38,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Start typing to search products',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ] else ...[
                                  const _EmptyCollection(),
                                ],
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate((ctx, i) {
                              final item = c.items[i];
                              return ProductCard<CollectionItem>(
                                item: item,
                                title: item.title,
                                image: item.image,
                                price: item.price,
                                offerPrice: null,
                                expiryBadges: const [],
                                onOpen: c.openItem,
                                onBookmark: c.addToCollection,
                                onAddToCart: c.addToCollection,
                                brandColor: _blue,
                              );
                            }, childCount: c.items.length),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.88,
                                ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: Center(
                            child: loadingMore
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Dedicated, local search field for CollectionView only.
class _CollectionSearchField extends StatelessWidget {
  const _CollectionSearchField({
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    );

    return Container(
      height: 46, // ✅ slimmer pill to match toolbar nicely
      margin: const EdgeInsets.only(right: 12), // tiny right breathing room
      decoration: BoxDecoration(
        color: const Color(0xFFE7EDF3), // soft, clean bg
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        cursorColor: Colors.black54,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
          ), // ✅ no extra height
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          prefixIcon: const Icon(Icons.search, size: 18, color: Colors.black54),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.black54,
                ),
                onPressed: () {
                  controller.clear();
                  onChanged?.call('');
                  FocusScope.of(context).unfocus();
                },
                tooltip: 'Clear',
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(Icons.inventory_2_outlined, size: 48, color: Colors.black38),
        SizedBox(height: 12),
        Text(
          'No items found',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarBackButton extends StatelessWidget {
  const _ToolbarBackButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE7EDF3),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onPressed,
        child: const SizedBox(
          height: 46, // matches search height
          width: 46, // square pill button
          child: Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Colors.black87,
              semanticLabel: 'Back',
            ),
          ),
        ),
      ),
    );
  }
}
