import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../combine_model/product_model.dart';
import '../combine_service/location_service.dart';
import '../routes/app_routes.dart';
import '../storage/token_storage.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const _pad = 16.0;

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(controller: c)),
            SliverToBoxAdapter(
              child: AppSearchBar(
                controller: c.searchCtrl,
                hintText: 'Search area or store',
                onTap: () {
                  Get.toNamed(AppRoutes.collection, arguments: {'fromHome': true});
                },
              ),
            ),



            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(_pad, 16, _pad, 8),
                child: Text(
                  'Categories',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _CategoriesStrip(controller: c)),
            SliverToBoxAdapter(child: _BannerCarousel(controller: c)),
            // Regular Offer
            SliverToBoxAdapter(
              child: Obx(() {
                final isLoading = c.isLoadingRegular.value;
                final err = c.regularError.value;
                final items = c.regularProducts;

                return _Section(
                  title: 'Regular Offer',
                  onSeeAll: () => c.onTapSeeAll('Regular Offer'),
                  child: _sectionBody(
                    isLoading: isLoading,
                    error: err,
                    onRetry: c.refreshRegular,
                    items: items,
                    onOpen: c.onOpen,
                    onAdd: c.onBookmark,
                    expiringStyle: false,
                  ),
                );
              }),
            ),

            // Expiring Offer
            SliverToBoxAdapter(
              child: Obx(() {
                final isLoading = c.isLoadingExpiring.value;
                final err = c.expiringError.value;
                final items = c.expiringProducts;

                return _Section(
                  title: 'Expiring Offer',
                  onSeeAll: () => c.onTapSeeAll('Expiring Offer'),
                  child: _sectionBody(
                    isLoading: isLoading,
                    error: err,
                    onRetry: c.refreshExpiring,
                    items: items,
                    onOpen: c.onOpen,
                    onAdd: c.onBookmark,
                    expiringStyle: true,
                  ),
                );
              }),
            ),

            // Clearance Offer
            SliverToBoxAdapter(
              child: Obx(() {
                final isLoading = c.isLoadingClearance.value;
                final err = c.clearanceError.value;
                final items = c.clearanceProducts;

                return _Section(
                  title: 'Clearance Offer',
                  onSeeAll: () => c.onTapSeeAll('Clearance Offer'),
                  child: _sectionBody(
                    isLoading: isLoading,
                    error: err,
                    onRetry: c.refreshClearance,
                    items: items,
                    onOpen: c.onOpen,
                    onAdd: c.onBookmark,
                    expiringStyle: false,
                  ),
                );
              }),
            ),

            // Seasonal Offer  (design like Expiring → expiringStyle: true)
            SliverToBoxAdapter(
              child: Obx(() {
                final isLoading = c.isLoadingSeasonal.value;
                final err = c.seasonalError.value;
                final items = c.seasonalProducts;

                return _Section(
                  title: 'Seasonal Offer',
                  onSeeAll: () => c.onTapSeeAll('Seasonal Offer'),
                  child: _sectionBody(
                    isLoading: isLoading,
                    error: err,
                    onRetry: c.refreshSeasonal,
                    items: items,
                    onOpen: c.onOpen,
                    onAdd: c.onBookmark,
                    expiringStyle: true, // ← same style as Expiring
                  ),
                );
              }),
            ),

// Service Special Offer (design like Regular/Clearance → expiringStyle: false)
            SliverToBoxAdapter(
              child: Obx(() {
                final isLoading = c.isLoadingServiceSpecial.value;
                final err = c.serviceSpecialError.value;
                final items = c.serviceSpecialProducts;

                return _Section(
                  title: 'Service Special Offer',
                  onSeeAll: () => c.onTapSeeAll('Service Special Offer'),
                  child: _sectionBody(
                    isLoading: isLoading,
                    error: err,
                    onRetry: c.refreshServiceSpecial,
                    items: items,
                    onOpen: c.onOpen,
                    onAdd: c.onBookmark,
                    expiringStyle: false, // ← like Regular/Clearance
                  ),
                );
              }),
            ),


            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
      ),
    );
  }
}

// ------------- Header -------------
class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Padding(
      padding: const EdgeInsets.fromLTRB(HomeView._pad, 8, HomeView._pad, 6),
      child: Row(
        children: [
          // Left: brand logo image
          // header - left logo
          Transform(
            alignment: Alignment.centerLeft,
            transform: Matrix4.identity()
              ..translate(-16.0, 0.0) // ← move 16px to the left
              ..scale(5.0), // your big scale
            child: Image.asset(
              'assets/png/home_logo.png',
              height: 32,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ),

          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FutureBuilder<List<dynamic>>(
                future: Future.wait<dynamic>([
                  TokenStorage.getToken(),
                  LocationService.getUserLocation(), // runs regardless of token
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading...");
                  }

                  final token    = snapshot.data?[0] as String?;
                  final location = (snapshot.data?[1] as String?) ?? "Detecting...";

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Hello, ${token == null ? 'Guest' : c.username}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded, size: 16, color: HomeController.blue),
                          const SizedBox(width: 4),
                          Text(location, style: const TextStyle(color: Colors.black87)),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          )

        ],
      ),
    );
  }
}

// ------------- Search (filter inside the bar) -------------

// ------------- Categories strip -------------
class _CategoriesStrip extends StatelessWidget {
  const _CategoriesStrip({required this.controller});
  final HomeController controller;

  static const double _tileWidth = 70;
  static const double _tileHeight = 45;
  static const double _radius = 12;

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Obx(() {
      // 1) Loading state → simple skeletons
      if (c.isLoadingCategories.value) {
        return SizedBox(
          height: 80,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: HomeView._pad,
              vertical: 2,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, __) => const _SkeletonTile(),
          ),
        );
      }

      // 2) Error state → message + retry
      final err = c.categoriesError.value;
      if (err != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: HomeView._pad),
          child: Container(
            height: 80,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to load categories',
                    style: const TextStyle(color: Colors.redAccent),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: c.refreshCategories,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      // 3) Empty state → subtle hint
      if (c.categories.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: HomeView._pad),
          child: SizedBox(
            height: 80,
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.black54),
                SizedBox(width: 8),
                Text('No categories found'),
              ],
            ),
          ),
        );
      }

      // 4) Normal state (CLICKABLE)
      return SizedBox(
        height: 80,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: HomeView._pad,
            vertical: 2,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: c.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final cat = c.categories[i]; // expects fields: id, name, image
            return SizedBox(
              width: _tileWidth,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(_radius),
                  onTap: () {
                    // Navigate with category id (and name)
                    Get.toNamed(
                      AppRoutes.collection, // change if your route key differs
                      parameters: {
                        'category_id': cat.id.toString(),
                        'category_name': cat.name,
                      },
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(_radius),
                        child: SizedBox(
                          width: double.infinity,
                          height: _tileHeight,
                          child: Image.network(
                            cat.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFEAEFF4),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}


class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _CategoriesStrip._tileWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // image placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(_CategoriesStrip._radius),
            child: Container(
              width: double.infinity,
              height: _CategoriesStrip._tileHeight,
              color: const Color(0xFFEAEFF4),
            ),
          ),
          const SizedBox(height: 4),
          // text bar placeholder
          Container(
            width: 48,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFEAEFF4),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------- Banner carousel -------------
class _BannerCarousel extends StatelessWidget {
  const _BannerCarousel({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Padding(
      padding: const EdgeInsets.fromLTRB(HomeView._pad, 4, HomeView._pad, 12),
      child: Obx(() {
        if (c.isLoadingBanners.value) {
          return Column(
            children: const [
              _BannerSkeleton(),
              SizedBox(height: 8),
              _DotsSkeleton(count: 3),
            ],
          );
        }

        if (c.bannersError.value != null) {
          return Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Failed to load sliders',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              TextButton(
                onPressed: c.refreshBanners,
                child: const Text('Retry'),
              ),
            ],
          );
        }

        if (c.banners.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            AspectRatio(
              aspectRatio: 20 / 8.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Listener(
                  onPointerDown: (_) => c.pauseAutoPlay(),
                  onPointerCancel: (_) => c.resumeAutoPlay(),
                  onPointerUp: (_) => c.resumeAutoPlay(),
                  child: PageView.builder(
                    controller: c.bannerCtrl,
                    itemCount: c.banners.length,
                    // Optional: keep index synced even without controller listener
                    onPageChanged: (i) => c.currentBanner.value = i,
                    itemBuilder: (_, i) {
                      final b = c.banners[i];
                      final hasText =
                          (b.title?.isNotEmpty ?? false) ||
                          (b.subtitle?.isNotEmpty ?? false);

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            b.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFEAEFF4),
                              alignment: Alignment.center,
                              child: const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                          if (hasText) ...[
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(.35),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, .5],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 14,
                              top: 14,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if ((b.title ?? '').isNotEmpty)
                                    Text(
                                      b.title!,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  if ((b.subtitle ?? '').isNotEmpty)
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.6,
                                      child: Text(
                                        b.subtitle!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  if ((b.title ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Material(
                                      color: Colors.white,
                                      shape: StadiumBorder(
                                        side: BorderSide(
                                          color: Colors.black.withOpacity(.1),
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () =>
                                            Get.snackbar('Banner', b.title!),
                                        customBorder: const StadiumBorder(),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            'See More',
                                            style: TextStyle(
                                              color: HomeController.blue,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  c.banners.length,
                  (i) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (c.currentBanner.value == i)
                          ? HomeController.blue
                          : HomeController.blue.withOpacity(.3),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}

class _BannerSkeleton extends StatelessWidget {
  const _BannerSkeleton();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 20 / 8.2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(color: const Color(0xFFEAEFF4)),
      ),
    );
  }
}

class _DotsSkeleton extends StatelessWidget {
  const _DotsSkeleton({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black12,
          ),
        ),
      ),
    );
  }
}

// ------------- Section wrapper -------------
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    required this.onSeeAll,
  });

  final String title;
  final Widget child;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              HomeView._pad,
              8,
              HomeView._pad,
              10,
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: onSeeAll,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('See All'),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ------------- Horizontal product row -------------
class _ProductsRow extends StatelessWidget {
  const _ProductsRow({
    required this.items,
    required this.onOpen,
    required this.onAdd,
    this.expiringStyle = false,
  });

  final List<ProductItems> items;
  final void Function(ProductItems) onOpen;
  final void Function(ProductItems) onAdd;
  final bool expiringStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.h,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: HomeView._pad),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final p = items[i];
          return SizedBox(
            width: 170,
            child: ProductCard<ProductItems>(
              item: p,
              title: p.title,
              image: p.image,
              price: p.price,
              offerPrice: p.offerPrice,
              expiryBadges: p.expiryBadges ?? const [],
              onOpen: (it) => onOpen(it),
              onAdd:  (it) => onAdd(it),
              expiringStyle: expiringStyle,
              brandColor: HomeController.blue,
            ),
          );
        },
      ),
    );
  }
}

// ------------- Product card -------------


Widget _sectionBody({
  required bool isLoading,
  required String? error,
  required VoidCallback onRetry,
  required List<ProductItems> items,
  required void Function(ProductItems) onOpen,
  required void Function(ProductItems) onAdd,
  required bool expiringStyle,
}) {
  if (isLoading) {
    return SizedBox(
      height: 200,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  if (error != null) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HomeView._pad),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Failed to load products',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  if (items.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HomeView._pad),
      child: SizedBox(
        height: 40,
        child: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.black54),
            SizedBox(width: 8),
            Text('No products found'),
          ],
        ),
      ),
    );
  }

  // Normal state
  return _ProductsRow(
    items: items,
    onOpen: onOpen,
    onAdd: onAdd,
    expiringStyle: expiringStyle,
  );
}
