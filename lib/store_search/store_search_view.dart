import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../widgets/app_bottom_nav.dart';
import 'store_search_controller.dart';

class StoreSearchView extends StatelessWidget {
  StoreSearchView({super.key});

  // No binding: create the controller here
  final StoreSearchController c = Get.put(StoreSearchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _SearchBar(c: c),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (c.loading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (c.stores.isEmpty) {
                  return const Center(child: Text('No stores found'));
                }
                return ListView.separated(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: c.stores.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _StoreTile(
                    data: c.stores[i],
                    onTap: c.openStore,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      // index 1 = your Search tab (make sure _routeByIndex maps 1 -> search route)
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.c});
  final StoreSearchController c;

  @override
  Widget build(BuildContext context) {
    const double height = 50;
    const double radius = height / 2;
    const double capWidth = 70; // wider than height => oval/pill cap

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            children: [
              // base (light background)
              Container(color: const Color(0xFFD7E1EB)),

              // search input; leave room for the right cap
              Positioned.fill(
                right: capWidth,
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: Colors.black87, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: c.queryCtrl,
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

              // right pill (both ends curved)
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
                        color: Color(0xFF124A89),
                        shape: StadiumBorder(), // 👈 curves BOTH sides
                      ),
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: c.openFilters,
                        child: Center(
                          child: InkWell(
                            customBorder: const StadiumBorder(),
                            onTap: c.openFilters,
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/svg/search_filter.svg',   // 👈 your file
                                width: 22,                        // same visual size as Icon(size: 32)
                                height: 22,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,                   // force white on blue background
                                  BlendMode.srcIn,
                                ),
                                // semanticsLabel: 'Filter',
                              ),
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



class _StoreTile extends StatelessWidget {
  const _StoreTile({required this.data, required this.onTap});
  final StoreItem data;
  final void Function(StoreItem) onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onTap(data),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _Logo(logo: data.logo),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            data.category,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),

                        const SizedBox(width: 8),

                          Text(
                            data.phone,
                           // overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54, fontSize: 12),
                          ),

                      ],
                    ),
                  ],

                ),
              ),
              TextButton(
                onPressed: () => onTap(data),
                child: const Text('View'),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.logo});
  final String logo;

  @override
  Widget build(BuildContext context) {
    final isAsset = !logo.startsWith('http');
    const size = 36.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: isAsset
          ? Image.asset(logo, width: size, height: size, fit: BoxFit.cover)
          : Image.network(logo, width: size, height: size, fit: BoxFit.cover),
    );
  }
}
