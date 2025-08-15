import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../widgets/app_bottom_nav.dart';
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
            SliverToBoxAdapter(child: _SearchBar(controller: c)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(_pad, 16, _pad, 8),
                child: Text('Categories',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            SliverToBoxAdapter(child: _CategoriesStrip(controller: c)),
            SliverToBoxAdapter(child: _BannerCarousel(controller: c)),
            SliverToBoxAdapter(
              child: _Section(
                title: 'Regular Offer',
                onSeeAll: () => c.onTapSeeAll('Regular Offer'),
                child: _ProductsRow(
                  items: c.regularProducts,
                  onOpen: c.onOpen,
                  onAdd: c.onAdd,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _Section(
                title: 'Expiring Offer',
                onSeeAll: () => c.onTapSeeAll('Expiring Offer'),
                child: _ProductsRow(
                  items: c.expiringProducts,
                  onOpen: c.onOpen,
                  onAdd: c.onAdd,
                  expiringStyle: true,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _Section(
                title: 'Clearance Offer',
                onSeeAll: () => c.onTapSeeAll('Clearance Offer'),
                child: _ProductsRow(
                  items: c.clearanceProducts,
                  onOpen: c.onOpen,
                  onAdd: c.onAdd,
                ),
              ),
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
              ..translate(-16.0, 0.0)  // ← move 16px to the left
              ..scale(5.0),            // your big scale
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
              Text('Hello, ${c.username}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black87)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 16, color: HomeController.blue),
                  const SizedBox(width: 4),
                  Text(c.location, style: const TextStyle(color: Colors.black87)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ------------- Search (filter inside the bar) -------------
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;

    const double height = 50;
    const double radius = height / 2;
    const double capWidth = 70; // wider than height => oval right cap

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HomeView._pad),
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            children: [
              // base background
              Container(color: const Color(0xFFD7E1EB)),

              // search input, leaving space for the right pill
              Positioned.fill(
                right: capWidth,
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: Colors.black87, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: c.searchCtrl,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Search area or store',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // right pill (both ends curved), acts as Filter button
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: SizedBox(
                  width: capWidth,
                  child: Material(
                    color: Colors.transparent,
                    child: Ink(
                      decoration: const ShapeDecoration(
                        color: HomeController.blue, // #124A89
                        shape: StadiumBorder(),
                      ),
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: c.onTapFilter,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/svg/search_filter.svg',
                            width: 22,
                            height: 22,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
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

// ------------- Categories strip -------------
class _CategoriesStrip extends StatelessWidget {
  const _CategoriesStrip({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;

    const double tileWidth = 70;   // ↓ narrower
    const double tileHeight = 45;  // ↓ shorter image
    const double radius = 12;      // ↓ tighter corners

    return SizedBox(
      height: 80, // overall strip height (very compact)
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: HomeView._pad,
          vertical: 2,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: c.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final cat = c.categories[i];

          return SizedBox(
            width: tileWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: SizedBox(
                    width: double.infinity,
                    height: tileHeight,
                    child: Image.network(cat.image, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cat.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,          // ↓ smaller label
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
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
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 20/ 8.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: PageView.builder(
                controller: c.bannerCtrl,
                itemCount: c.banners.length,
                itemBuilder: (_, i) {
                  final b = c.banners[i];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(b.image, fit: BoxFit.cover),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(.35),
                                Colors.transparent
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
                            const Text('New Collection',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w700)),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                b.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Material(
                              color: Colors.white,
                              shape: StadiumBorder(
                                side: BorderSide(
                                    color: Colors.black.withOpacity(.1)),
                              ),
                              child: InkWell(
                                onTap: () => Get.snackbar('Banner', b.title),
                                customBorder: const StadiumBorder(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  child: Text('See More',
                                      style: TextStyle(
                                          color: HomeController.blue,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
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
            padding:
            const EdgeInsets.fromLTRB(HomeView._pad, 8, HomeView._pad, 10),
            child: Row(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
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

  final List<ProductItem> items;
  final void Function(ProductItem) onOpen;
  final void Function(ProductItem) onAdd;
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
            child: _ProductCard(
              item: p,
              onOpen: onOpen,
              onAdd: onAdd,
              expiringStyle: expiringStyle,
            ),
          );
        },
      ),
    );
  }
}

// ------------- Product card -------------
class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.item,
    required this.onOpen,
    required this.onAdd,
    this.expiringStyle = false,
  });

  final ProductItem item;
  final void Function(ProductItem) onOpen;
  final void Function(ProductItem) onAdd;
  final bool expiringStyle;

  static const _radius = 14.0;

  @override
  Widget build(BuildContext context) {
    final hasOffer = item.offerPrice != null;

    return InkWell(
      borderRadius: BorderRadius.circular(_radius),
      onTap: () => onOpen(item),
      child: Ink(
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
              Positioned.fill(
                child: Image.network(item.image, fit: BoxFit.cover),
              ),

              // Optional expiry badges
              if (expiringStyle && (item.expiryBadges?.isNotEmpty ?? false))
                Positioned(
                  top: 8,
                  left: 8,
                  child: Row(
                    children: item.expiryBadges!
                        .map((t) => Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(t,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 11)),
                    ))
                        .toList(),
                  ),
                ),

              // Strong blue bottom text background (transparent → solid)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        HomeController.blue.withOpacity(0.75),
                        HomeController.blue.withOpacity(0.92),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
                  child: Row(
                    children: [
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
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  '\$${item.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: hasOffer ? Colors.white70 : Colors.white,
                                    decoration: hasOffer
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    fontSize: 12,
                                  ),
                                ),
                                if (hasOffer) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '\$${item.offerPrice!.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => onAdd(item),
                          child: const SizedBox(
                            width: 34,
                            height: 34,
                            child: Icon(Icons.add,
                                size: 20, color: HomeController.blue),
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

