// lib/store_details/store_details_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../combine_model/product_item_model.dart' show ProductItem;
import 'package:dealzy/store_details/store_products_service.dart';
import 'package:dealzy/combine_service/bookmark_service.dart'; // <-- import your BookmarkService

// If StoreInfo is in another file, import it instead of redefining here.
class StoreInfo {
  const StoreInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.phone,
    required this.openTime,   // "HH:mm"
    required this.closeTime,  // "HH:mm"
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String category;
  final String address;
  final String phone;
  final String openTime;
  final String closeTime;
  final String avatarUrl;
}

class StoreDetailsController extends GetxController {
  StoreDetailsController({
    StoreProductsService? service,
    BookmarkService? bookmarkService,
  })  : _service = service ?? StoreProductsService(),
        _bookmarkService = bookmarkService ?? BookmarkService();

  // Theme
  static const blue = Color(0xFF124A89);

  // Bottom sheet snap points (fraction of screen height)
  static const double collapsedSize = 0.08;
  static const double expandedSize  = 0.68;

  // UI state
  final isExpanded = false.obs;
  final RxDouble sheetSize = collapsedSize.obs;

  // Sheet controller
  late final DraggableScrollableController sheetCtrl;
  late final VoidCallback _sheetListener;

  // Data
  late final StoreInfo store;
  final products = <ProductItem>[].obs;

  // Loading / pagination
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  int _page = 1;
  int _totalPages = 1;
  final int _limit = 20;

  // Per-item bookmarking state (useful if you want to show a spinner on the + button)
  final bookmarking = <String>{}.obs; // holds product IDs currently bookmarking

  // Services
  final StoreProductsService _service;
  final BookmarkService _bookmarkService;

  // -------- Public API --------
  void back() => Get.back();

  void togglePanel() {
    final target = isExpanded.value ? collapsedSize : expandedSize;
    sheetCtrl.animateTo(
      target, duration: const Duration(milliseconds: 280), curve: Curves.easeInOut,
    );
  }

  /// Called by the ProductCard's + button
  Future<void> onAdd(ProductItem p) async {
    // prevent duplicate taps per item
    if (bookmarking.contains(p.id)) return;

    bookmarking.add(p.id);
    try {
      final res = await _bookmarkService.bookmarkProduct(p.id);
      if (res.isSuccess) {
        Get.snackbar(
          'Bookmarked',
          '${p.title} added to bookmarks',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'Failed',
          res.message.isEmpty ? 'Bookmark failed' : res.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade200,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade200,
      );
    } finally {
      bookmarking.remove(p.id);
    }
  }

  // -------- Hours / Open-Now helper --------
  bool get isOpenNow {
    final now = DateTime.now();
    final open = _parseToday(store.openTime);
    final close = _parseToday(store.closeTime);
    if (close.isBefore(open)) {
      return now.isAfter(open) || now.isBefore(close.add(const Duration(days: 1)));
    }
    return now.isAfter(open) && now.isBefore(close);
  }

  String get openLabel12h  => _format12h(store.openTime);
  String get closeLabel12h => _format12h(store.closeTime);

  // -------- Lifecycle --------
  @override
  void onInit() {
    super.onInit();

    sheetCtrl = DraggableScrollableController();
    _sheetListener = () {
      sheetSize.value = sheetCtrl.size;
      isExpanded.value = sheetCtrl.size > (collapsedSize + 0.08);
    };
    sheetCtrl.addListener(_sheetListener);

    // Read arguments (expects Get.arguments = {'store': {...}})
    final args = (Get.arguments as Map?)?.cast<String, dynamic>() ?? {};
    final m = (args['store'] as Map?)?.cast<String, dynamic>() ?? {};

    String _s(String k1, [String? k2]) =>
        ((m[k1] ?? (k2 != null ? m[k2] : '') ?? '') as Object).toString().trim();

    store = StoreInfo(
      id:        _s('id', 'store_id'),
      name:      _s('name', 'store_name'),
      category:  _s('type', 'store_type'),
      address:   _s('address'),
      phone:     _s('phone'),
      openTime:  _normTime(_s('opening', 'opening_time')),
      closeTime: _normTime(_s('closing', 'closing_time')),
      avatarUrl: _s('image', 'image_path'),
    );

    // Load products from API via service
    loadFirstPage();
  }

  @override
  void onClose() {
    sheetCtrl.removeListener(_sheetListener);
    sheetCtrl.dispose();
    _service.dispose();
    super.onClose();
  }

  // -------- Data loaders --------
  Future<void> loadFirstPage() async {
    _page = 1;
    isLoading.value = true;
    try {
      final res = await _service.fetchByStore(
        storeId: store.id,
        page: _page,
        limit: _limit,
      );
      products.assignAll(res.items);
      _totalPages = res.totalPages;
    } catch (e) {
      products.clear();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || _page >= _totalPages) return;
    isLoadingMore.value = true;
    try {
      final next = _page + 1;
      final res = await _service.fetchByStore(
        storeId: store.id,
        page: next,
        limit: _limit,
      );
      products.addAll(res.items);
      _page = res.currentPage;
      _totalPages = res.totalPages;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoadingMore.value = false;
    }
  }

  // -------- Private helpers --------
  String _normTime(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '10:00';
    final p = t.split(':');
    final h = int.tryParse(p[0]) ?? 10;
    final m = int.tryParse(p.length > 1 ? p[1] : '0') ?? 0;
    final hh = h.clamp(0, 23).toString().padLeft(2, '0');
    final mm = m.clamp(0, 59).toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  DateTime _parseToday(String hhmm24) {
    final parts = hhmm24.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }

  String _format12h(String hhmm24) {
    final dt = _parseToday(hhmm24);
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final mm = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    return '$h12:$mm $ampm';
  }
}
