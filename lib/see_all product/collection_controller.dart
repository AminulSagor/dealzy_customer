// lib/collection/collection_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dealzy/storage/token_storage.dart';
import 'package:dealzy/widgets/login_required_dialog.dart';

import '../combine_service/bookmark_service.dart';
import '../home/home_service.dart';
import '../home/home_products_model.dart';
import 'category_products_service.dart';

class CollectionItem {
  final String id;
  final String title;
  final double price;
  final String image;

  const CollectionItem({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
  });

  factory CollectionItem.fromCategoryProduct(CategoryProduct p) => CollectionItem(
    id: p.id,
    title: p.title,
    price: p.offerPrice ?? p.price,
    image: p.image,
  );

  factory CollectionItem.fromHomeDto(HomeProductDto p) {
    double _d(String? s) => double.tryParse((s ?? '').trim()) ?? 0.0;
    return CollectionItem(
      id: (p.id).toString(),
      title: p.name,
      price: (p.offerPrice != null && p.offerPrice!.isNotEmpty)
          ? _d(p.offerPrice)
          : _d(p.price),
      image: p.imagePath,
    );
  }
}

class CollectionController extends GetxController {
  CollectionController({
    CategoryProductsService? service,
    BookmarkService? bookmarkService,
    HomeService? homeService,
  })  : _service = service ?? CategoryProductsService(),
        _bookmarkService = bookmarkService ?? BookmarkService(),
        _homeService = homeService ?? HomeService();

  final CategoryProductsService _service;
  final BookmarkService _bookmarkService;
  final HomeService _homeService;

  // --- Params from navigation
  late final bool fromHome;
  final RxBool fromHomeRx = false.obs;
  late final String categoryId;
  late final String? categoryName;

  // NEW: offer mode (expiring_soon | clearance | regular)
  late final String offerType;   // '' when not in offer mode
  late final String screenTitle; // optional, for AppBar title

  // --- Search state
  final TextEditingController searchCtrl = TextEditingController();
  final RxString query = ''.obs;
  Worker? _debouncer;

  // --- UI data
  final RxList<CollectionItem> items = <CollectionItem>[].obs;

  // --- Paging + states
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final error = RxnString();
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final pageSize = 10.obs;

  // --- Bookmarking
  final RxSet<String> _bookmarking = <String>{}.obs;
  RxSet<String> get bookmarkingRx => _bookmarking;
  bool isBookmarking(String id) => _bookmarking.contains(id);

  // --- Scroll controller
  final ScrollController gridCtrl = ScrollController();

  void back() => Get.back();
  void openItem(CollectionItem i) => Get.toNamed('/product-details/${i.id}');

  bool get _isValidOffer =>
      const {'regular', 'expiring_soon', 'clearance'}.contains(offerType);

  @override
  void onInit() {
    super.onInit();

    final args = (Get.arguments as Map?)?.cast<String, dynamic>() ?? const {};
    fromHomeRx.value = args['fromHome'] == true; // <--- ADD THIS
    fromHome = fromHomeRx.value;

    // Route parameters (for category mode)
    categoryId = (Get.parameters['category_id'] ?? '').trim();
    categoryName = Get.parameters['category_name'];

    // Offer mode (for Home “See All”)
    offerType = (args['offer'] ?? '').toString().trim(); // '' if not provided
    screenTitle = (args['title'] ?? '').toString().trim();

    // Debounce search queries
    _debouncer = debounce<String>(
      query,
          (_) => fetchFirstPage(limit: pageSize.value),
      time: const Duration(milliseconds: 400),
    );

    // Prefill search if passed
    final prefill = (args['q'] as String?)?.trim();
    if ((prefill ?? '').isNotEmpty) {
      searchCtrl.text = prefill!;
      query.value = prefill;
    }

    // Initial fetch
    if (fromHome && query.value.isEmpty && offerType.isEmpty) {
      items.clear(); // wait for user typing
    } else {
      fetchFirstPage();
    }

    gridCtrl.addListener(_onGridScroll);
  }

  @override
  void onClose() {
    gridCtrl.removeListener(_onGridScroll);
    gridCtrl.dispose();
    searchCtrl.dispose();
    _debouncer?.dispose();
    _homeService.dispose();
    super.onClose();
  }

  void _onGridScroll() {
    if (!gridCtrl.hasClients) return;
    const threshold = 200.0;
    final pos = gridCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - threshold && !isLoadingMore.value) {
      loadMore();
    }
  }

  // --- Handlers for search bar
  void onSearchChanged(String q) {
    query.value = q;
    if (fromHome && q.trim().isEmpty && offerType.isEmpty) {
      // immediate idle state
      error.value = null;
      items.clear();
      totalPages.value = 1;
      currentPage.value = 1;
    }
  }

  void onSearchSubmitted(String q) => query.value = q;

  // --- Data
  Future<void> fetchFirstPage({int limit = 10}) async {
    isLoading.value = true;
    error.value = null;
    items.clear();
    currentPage.value = 1;
    pageSize.value = limit;

    // ⛳️ EARLY EXIT: fromHome with empty query (and not in offer mode) = idle state
    if (fromHome && query.value.trim().isEmpty && offerType.isEmpty) {
      totalPages.value = 1;
      isLoading.value = false;
      return; // ✅ do not hit category/offer/search branches
    }

    try {
      if (query.value.trim().isNotEmpty) {
        // SEARCH mode
        final page = await _service.searchProducts(
          keyword: query.value.trim(),
          page: 1,
          limit: limit,
        );
        currentPage.value = page.currentPage;
        totalPages.value = page.totalPages;
        items.assignAll(page.data.map(CollectionItem.fromCategoryProduct));
      } else if (_isValidOffer) {
        // OFFER mode
        final page = await _homeService.getHomeProducts(
          offer: offerType,
          page: 1,
          limit: limit,
        );
        currentPage.value = page.page;
        totalPages.value = page.totalPages;
        items.assignAll(page.products.map(CollectionItem.fromHomeDto));
      } else {
        // CATEGORY mode
        if (categoryId.isEmpty) {
          // If we ever get here without a category, treat like empty state instead of error.
          totalPages.value = 1;
          items.clear();
          return;
        }
        final page = await _service.fetchProductsByCategory(
          categoryId: categoryId,
          page: 1,
          limit: limit,
        );
        currentPage.value = page.currentPage;
        totalPages.value = page.totalPages;
        items.assignAll(page.data.map(CollectionItem.fromCategoryProduct));
      }
    } catch (e) {
      error.value = e.toString();
      items.clear();
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> loadMore() async {
    if (isLoadingMore.value) return;
    if (currentPage.value >= totalPages.value) return;

    // ⛳️ No pagination when idle (fromHome + empty query + no offer)
    if (fromHome && query.value.trim().isEmpty && offerType.isEmpty) return;

    isLoadingMore.value = true;
    try {
      final next = currentPage.value + 1;

      if (query.value.trim().isNotEmpty) {
        final page = await _service.searchProducts(
          keyword: query.value.trim(),
          page: next,
          limit: pageSize.value,
        );
        currentPage.value = page.currentPage;
        totalPages.value = page.totalPages;
        items.addAll(page.data.map(CollectionItem.fromCategoryProduct));
      } else if (_isValidOffer) {
        final page = await _homeService.getHomeProducts(
          offer: offerType,
          page: next,
          limit: pageSize.value,
        );
        currentPage.value = page.page;
        totalPages.value = page.totalPages;
        items.addAll(page.products.map(CollectionItem.fromHomeDto));
      } else {
        final page = await _service.fetchProductsByCategory(
          categoryId: categoryId,
          page: next,
          limit: pageSize.value,
        );
        currentPage.value = page.currentPage;
        totalPages.value = page.totalPages;
        items.addAll(page.data.map(CollectionItem.fromCategoryProduct));
      }
    } catch (_) {
      // optional: toast/log
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Plus button → bookmark product (requires auth)
  Future<void> addToCollection(CollectionItem i) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      Get.dialog(const LoginRequiredDialog(), barrierDismissible: false);
      return;
    }

    if (_bookmarking.contains(i.id)) return;
    _bookmarking.add(i.id);

    try {
      final res = await _bookmarkService.bookmarkProduct(i.id);
      Get.snackbar(
        'Saved',
        res.message.isNotEmpty ? res.message : 'Bookmarked “${i.title}”',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      _bookmarking.remove(i.id);
    }
  }
}