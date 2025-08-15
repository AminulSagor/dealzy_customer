import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PDStoreInfo {
  const PDStoreInfo({
    required this.name,
    required this.category,
    required this.address,
    required this.phone,
    required this.openTime, // "HH:mm"
    required this.closeTime, // "HH:mm"
  });

  final String name;
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
    required this.dateText, // e.g., "11/12/2024"
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

  final String title;
  final String brand;              // ✅ fixed
  final String model;              // "FS5878"
  final String color;              // "Only Black"
  final String sizeText;           // "44mm"
  final String category;           // "Men’s Watch"
  final String availabilityText;   // "1 In Stock"
  final List<String> images;
  final double mrp;
  final double offerPrice;
  final double rating;
  final String description;
}

class ProductDetailsController extends GetxController {
  static const blue = Color(0xFF124A89);

  late final ProductDetails product;
  late final PDStoreInfo store;
  final reviews = <PDReview>[].obs;

  // carousel
  final pageCtrl = PageController();
  final currentPage = 0.obs;

  // description expand/collapse
  final descExpanded = false.obs;

  // review expand/collapse (for the first review in mock)
  final firstReviewExpanded = false.obs;

  void toggleDesc() => descExpanded.toggle();
  void toggleFirstReview() => firstReviewExpanded.toggle();

  void onBookmark() {
    Get.snackbar('Saved', 'Bookmarked this product',
        snackPosition: SnackPosition.BOTTOM);
  }

  void viewStore() {
    // TODO: navigate to your Store Details page
    // Get.toNamed(AppRoutes.storeDetails);
  }

  bool get isOpenNow {
    final now = DateTime.now();
    final open = _parseToday(store.openTime);
    final close = _parseToday(store.closeTime);
    if (close.isBefore(open)) {
      return now.isAfter(open) || now.isBefore(close.add(const Duration(days: 1)));
    }
    return now.isAfter(open) && now.isBefore(close);
  }

  String get openLabel12h => _format12h(store.openTime);
  String get closeLabel12h => _format12h(store.closeTime);

  @override
  void onInit() {
    super.onInit();

    // --- Dummy data (edit as needed) ---
    product = ProductDetails(
      title: 'Fossil Bronson Chronograph Dark Red  Men\'s Watch | FS5878',
      brand: 'Fossil',                   // ✅ fixed usage
      model: 'FS5878',
      color: 'Only Black',
      sizeText: '44mm',
      category: 'Men’s Watch',
      availabilityText: '1 In Stock',
      images: const [
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1511735111819-9a3f7709049c?q=80&w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?q=80&w=800&auto=format&fit=crop',
      ],
      mrp: 67,
      offerPrice: 55,
      rating: 4.5,
      description:
      'Lorem ipsum is simply dummy text of the printing and typesetting industry. '
          'Lorem ipsum has specimen book. It has survived not only five centuries, '
          'but also the leap into electronic typesetting, remaining essentially unchanged...',
    );

    store = const PDStoreInfo(
      name: 'Fashion.Hube',
      category: 'clothing',
      address: 'jalalabad, sylhet',
      phone: '+88 016 4738 723',
      openTime: '10:00',
      closeTime: '21:30',
    );

    reviews.assignAll(const [
      PDReview(
        userName: 'Fouzia Hussain',
        userAvatar:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&auto=format&fit=crop',
        rating: 4.5,
        dateText: '11/12/2024',
        text:
        'Lorem ipsum is simply dummy text of the printing and typesetting industry. '
            'Lorem ipsum has been the industry’s standard dummy text ever since the, but also '
            'the leap into electronic typesetting, remaining essentially unchanged....',
      ),
    ]);

    pageCtrl.addListener(() {
      final p = pageCtrl.page ?? 0.0;
      currentPage.value = p.round();
    });
  }

  @override
  void onClose() {
    pageCtrl.dispose();
    super.onClose();
  }

  // helpers
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
