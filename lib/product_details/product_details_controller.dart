// controllers/product_details_controller.dart
import 'package:dealzy/product_details/product_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../combine_service/bookmark_service.dart';
import '../widgets/login_required_dialog.dart';

class PDStoreInfo {
  const PDStoreInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.phone,
    required this.openTime, // "HH:mm"
    required this.closeTime, // "HH:mm"
  });

  final String name;
  final String id;
  final String category;
  final String address;
  final String phone;
  final String openTime;
  final String closeTime;
}

class PDReview {
  const PDReview({
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.dateText,
    required this.text,
  });
  final String userName;
  final String userAvatar;
  final double rating;
  final String dateText;
  final String text;
}

class ProductDetails {
  const ProductDetails({
    required this.id,
    required this.title,
    required this.brand,
    required this.model,
    required this.color,
    required this.sizeText,
    required this.category,
    required this.availabilityText,
    required this.images,
    required this.mrp,
    required this.offerPrice,
    required this.rating,
    required this.description,
  });
  final String id;
  final String title;
  final String brand;
  final String model;
  final String color;      // comma-joined colors from API
  final String sizeText;   // comma-joined variants from API
  final String category;
  final String availabilityText;
  final List<String> images;
  final double mrp;
  final double offerPrice; // if no discount, same as mrp
  final double rating;     // not in API ⇒ keep 0 or compute later
  final String description;
}

class ProductDetailsController extends GetxController {
  ProductDetailsController({
    ProductService? service,
    String? productId,
    BookmarkService? bookmarkService,
  })  : _service = service ?? ProductService(),
        _bookmark = bookmarkService ?? BookmarkService(),
        _productId = productId ??
            // 1) path like /product-details/:id
            (Get.parameters['id'] ??
                // 2) query like /product-details?product_id=4
                Get.parameters['product_id'] ??
                // 3) Get.arguments = {'product_id': 4} or 4
                (() {
                  final a = Get.arguments;
                  if (a is Map && a['product_id'] != null) return a['product_id'].toString();
                  if (a != null) return a.toString();
                  return '';
                })());

  static const blue = Color(0xFF124A89);

  final ProductService _service;
  final BookmarkService _bookmark;
  final String _productId;

  // state
  final isLoading = true.obs;
  final error = RxnString();

  late ProductDetails product;
  late PDStoreInfo store;
  final reviews = <PDReview>[].obs;

  // carousel & UI states
  final pageCtrl = PageController();
  final currentPage = 0.obs;
  final descExpanded = false.obs;
  final firstReviewExpanded = false.obs;

  // bookmarking
  final isBookmarking = false.obs;

  void toggleDesc() => descExpanded.toggle();
  void toggleFirstReview() => firstReviewExpanded.toggle();

  Future<void> onBookmark() async {
    if (isBookmarking.value) return;
    if (product.id.isEmpty) return;

    try {
      isBookmarking.value = true;

      final res = await _bookmark.bookmarkProduct(product.id);

      Get.snackbar(
        'Saved',
        res.message.isNotEmpty ? res.message : 'Bookmarked this product',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );
    } on StateError catch (e) {
      // check if the error is about missing token
      if (e.message.contains('Missing token')) {
        Get.dialog(const LoginRequiredDialog(), barrierDismissible: false);
      } else {
        Get.snackbar(
          'Error',
          e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Bookmark failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isBookmarking.value = false;
    }
  }





  bool get isOpenNow {
    final now = DateTime.now();
    final open = _parseToday(store.openTime);
    final close = _parseToday(store.closeTime);
    if (close.isBefore(open)) {
      // overnight schedule
      return now.isAfter(open) || now.isBefore(close.add(const Duration(days: 1)));
    }
    return now.isAfter(open) && now.isBefore(close);
  }

  String get openLabel12h => _format12h(store.openTime);
  String get closeLabel12h => _format12h(store.closeTime);

  @override
  void onInit() {
    super.onInit();
    _load();
    pageCtrl.addListener(() {
      final p = pageCtrl.page ?? 0.0;
      currentPage.value = p.round();
    });
  }

  Future<void> _load() async {
    if (_productId.isEmpty) {
      error.value = 'No product id provided';
      isLoading.value = false;
      return;
    }
    try {
      isLoading.value = true;
      error.value = null;

      final api = await _service.fetchDetails(_productId);

      // Map API model -> UI model your widgets already use
      product = ProductDetails(
        id: api.id,
        title: api.name,
        brand: api.brand,
        model: api.model,
        color: api.colorOneLine,              // "Red, Blue"
        sizeText: api.variantOneLine,         // "64GB, 32GB"
        category: api.category,
        availabilityText: api.availabilityText,
        images: api.images,
        mrp: api.price,
        offerPrice: api.hasDiscount ? api.finalPrice : api.price,
        rating: 0, // API doesn't provide rating; keep 0 or compute later
        description: api.description,
      );

      store = PDStoreInfo(
        name: api.storeName,
        id: api.sellerId,
        category: api.storeType,
        address: api.address,
        phone: api.phone,
        openTime: api.openingTimeHHmm,
        closeTime: api.closingTimeHHmm,

      );

      // If/when you add real reviews API, replace this:
      reviews.assignAll(const []);

    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    pageCtrl.dispose();
    super.onClose();
  }

  DateTime _parseToday(String hhmm24) {
    final parts = hhmm24.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }

  String _format12h(String hhmm24) {
    final dt = _parseToday(hhmm24);
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    return '$h:$m $ampm';
  }




}
