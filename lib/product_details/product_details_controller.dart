import 'package:dealzy/combine_service/add_to_cart_service.dart';
import 'package:dealzy/product_details/product_service.dart';
import 'package:dealzy/product_details/report_service.dart'; // <-- keep this
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../combine_service/bookmark_service.dart';
import '../storage/token_storage.dart';
import '../widgets/login_required_dialog.dart';

class PDStoreInfo {
  const PDStoreInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.phone,
    required this.openTime,
    required this.closeTime,
    this.photoUrl,
  });

  final String name;
  final String id;
  final String category;
  final String address;
  final String phone;
  final String openTime;
  final String closeTime;
  final String? photoUrl;
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
  final String color;
  final String sizeText;
  final String category;
  final String availabilityText;
  final List<String> images;
  final double mrp;
  final double offerPrice;
  final double rating;
  final String description;
}

class ProductDetailsController extends GetxController {
  ProductDetailsController({
    ProductService? service,
    String? productId,
    BookmarkService? bookmarkService,
    AddToCartService? addToCartService,
    ReportService? reportService, // <-- allow DI (optional)
  }) : _service = service ?? ProductService(),
       _bookmark = bookmarkService ?? BookmarkService(),
       _addToCart = addToCartService ?? AddToCartService(),
       _reportService = reportService ?? ReportService(), // <-- init here
       _productId =
           productId ??
           (Get.parameters['id'] ??
               Get.parameters['product_id'] ??
               (() {
                 final a = Get.arguments;
                 if (a is Map && a['product_id'] != null)
                   return a['product_id'].toString();
                 if (a != null) return a.toString();
                 return '';
               })());

  static const blue = Color(0xFF124A89);

  final ProductService _service;
  final BookmarkService _bookmark;
  final AddToCartService _addToCart;
  final ReportService _reportService; // <-- field
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

  // reporting
  final isReporting = false.obs;
  // at top of HomeController
  final isLoggedIn = false.obs;
  final blockedSellerIds = <String>{}.obs;
  // cart state
  final isAddingToCart = false.obs;

  void toggleDesc() => descExpanded.toggle();
  void toggleFirstReview() => firstReviewExpanded.toggle();

  Future<void> onAddToCart() async {
    if (isAddingToCart.value) return;
    if (product.id.isEmpty) return;

    try {
      isAddingToCart.value = true;

      // 🔹 Optional: check login
      // final token = await TokenStorage.getToken();
      // if (token == null || token.isEmpty) {
      //   Get.dialog(const LoginRequiredDialog(), barrierDismissible: false);
      //   return;
      // }

      final res = await _addToCart.addToCart(product.id);

      Get.snackbar(
        'Added to Cart',
        res.message.isNotEmpty
            ? res.message
            : '${product.title} was added successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );
    } on StateError catch (e) {
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
        'Add to cart failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isAddingToCart.value = false;
    }
  }

  Future<void> onBookmark() async {
    if (isBookmarking.value) return;
    if (product.id.isEmpty) return;

    try {
      isBookmarking.value = true;
      final res = await _bookmark.bookmarkProduct(product.id);
      Get.snackbar(
        'Saved',
        res.message.isNotEmpty ? res.message : 'Bookmarked this product',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );
    } on StateError catch (e) {
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

  // ✅ Use ReportService instead of raw http
  Future<void> reportProduct(String message) async {
    if (isReporting.value) return;
    if (product.id.isEmpty) {
      Get.snackbar(
        'Report',
        'Missing product id',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
      );
      return;
    }

    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      Get.dialog(const LoginRequiredDialog(), barrierDismissible: false);
      return;
    }

    try {
      isReporting.value = true;

      final resp = await _reportService.reportProduct(
        productId: product.id,
        reportText: message,
        token: token, // ✅ pass token here
      );

      final status = (resp['status'] ?? '').toString().toLowerCase();

      if (status == 'success') {
        Get.snackbar(
          'Report sent',
          'Thanks. We’ll review within 24 hours and take appropriate action.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade600, // ✅ green background
          colorText: Colors.white, // white text
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Report failed',
          'Please try again in a moment.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade700, // red background for failure
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Report failed',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      isReporting.value = false;
    }
  }

  bool get isOpenNow {
    final now = DateTime.now();
    final open = _parseToday(store.openTime);
    final close = _parseToday(store.closeTime);
    if (close.isBefore(open)) {
      return now.isAfter(open) ||
          now.isBefore(close.add(const Duration(days: 1)));
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

      product = ProductDetails(
        id: api.id,
        title: api.name,
        brand: api.brand,
        model: api.model,
        color: api.colorOneLine,
        sizeText: api.variantOneLine,
        category: api.category,
        availabilityText: api.availabilityText,
        images: api.images,
        mrp: api.price,
        offerPrice: api.hasDiscount ? api.finalPrice : api.price,
        rating: 0,
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
        photoUrl: api.proPath,
      );

      reviews.assignAll(const []);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // inside ProductDetailsController

  void goToStoreDetails() {
    Get.toNamed(
      '/store-details', // or AppRoutes.storeDetails
      arguments: {
        'store': {
          'id': store.id,
          'name': store.name,
          'type': store.category,
          'address': store.address,
          'phone': store.phone,
          'opening_time': store.openTime,
          'closing_time': store.closeTime,
          'image': store.photoUrl ?? '',
        },
      },
    );
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
