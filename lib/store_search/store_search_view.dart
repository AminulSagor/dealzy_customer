import 'package:dealzy/store_search/store_item_model.dart';
import 'package:dealzy/store_search/store_search_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/app_bottom_nav.dart';
        // SuggestionItem { adminDis, postCode? }
import 'filter_service.dart';
import 'store_search_controller.dart';

class StoreSearchView extends StatelessWidget {
  StoreSearchView({super.key});

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
                if (c.loading.value) return const Center(child: CircularProgressIndicator());

                if (c.error.value != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Failed: ${c.error.value}", style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 8),
                        TextButton(onPressed: c.fetchSuggestions, child: const Text("Retry")),
                      ],
                    ),
                  );
                }

                // Decide which list to show
                if (!c.showingStores.value) {
                  // SUGGESTIONS
                  if (c.suggestions.isEmpty) return const Center(child: Text('No suggestions'));
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: c.suggestions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _SuggestionTile(
                      data: c.suggestions[i],
                      onTap: c.selectSuggestionAndSearch,
                    ),
                  );
                } else {
                  // STORES
                  if (c.stores.isEmpty) return const Center(child: Text('No stores found'));
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: c.stores.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _StoreTile(
                      data: c.stores[i],
                      onTap: c.openStore,
                    ),
                  );
                }
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.c});
  final StoreSearchController c;

  @override
  Widget build(BuildContext context) {
    const double height = 50, radius = height / 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            color: const Color(0xFFD7E1EB),
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
                      hintText: 'Search area or post code',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                // optional filter icon on right

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.data, required this.onTap});
  final SuggestionItem data;
  final void Function(SuggestionItem) onTap;

  @override
  Widget build(BuildContext context) {
    final hasPostCode = (data.postCode ?? '').isNotEmpty;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onTap(data), // will trigger API with post_code
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.adminDis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    if (hasPostCode)
                      Text(data.postCode!,
                          style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
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
    const logoSize = 44.0;
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
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.network(
                  data.image,
                  width: logoSize, height: logoSize, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: logoSize, height: logoSize,
                    color: const Color(0xFFEAEFF4),
                    alignment: Alignment.center,
                    child: const Icon(Icons.store, color: Colors.black38),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name on two parts look
                    Text(
                      data.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            data.type,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "•",
                          style: TextStyle(color: Colors.black38, fontSize: 12),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            data.phone, // ✅ show address instead
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: () => onTap(data), child: const Text('View')),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
