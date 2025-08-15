import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductItem {
  const ProductItem({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
  });
  final String id;
  final String title;
  final double price;
  final String image;
}

class StoreInfo {
  const StoreInfo({
    required this.name,
    required this.category,
    required this.address,
    required this.phone,
    required this.openTime, // 24h "HH:mm"
    required this.closeTime, // 24h "HH:mm"
    required this.avatarUrl,
  });

  final String name;
  final String category;
  final String address;
  final String phone;
  final String openTime;
  final String closeTime;
  final String avatarUrl;
}

class StoreDetailsController extends GetxController {
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

  // --- Public API ---
  void back() => Get.back();

  void togglePanel() {
    final target = isExpanded.value ? collapsedSize : expandedSize;
    sheetCtrl.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void onAdd(ProductItem p) {
    // TODO: integrate with cart/collection
    Get.snackbar('Added', '${p.title} added to cart',
        snackPosition: SnackPosition.BOTTOM);
  }

  // --- Hours / Open-Now helper ---
  bool get isOpenNow {
    final now = DateTime.now();
    final open = _parseToday(store.openTime);
    final close = _parseToday(store.closeTime);

    if (close.isBefore(open)) {
      // Handle ranges that pass midnight
      return now.isAfter(open) || now.isBefore(close.add(const Duration(days: 1)));
    }
    return now.isAfter(open) && now.isBefore(close);
  }

  String get openLabel12h  => _format12h(store.openTime);
  String get closeLabel12h => _format12h(store.closeTime);

  // --- Lifecycle ---
  @override
  void onInit() {
    super.onInit();

    // Init sheet controller + listener
    sheetCtrl = DraggableScrollableController();
    _sheetListener = () {
      sheetSize.value = sheetCtrl.size;
      isExpanded.value = sheetCtrl.size > (collapsedSize + 0.08); // small hysteresis
    };
    sheetCtrl.addListener(_sheetListener);

    // Dummy store
    store = const StoreInfo(
      name: 'Fashion.Hube',
      category: 'clothing',
      address: 'jalalabad, sylhet',
      phone: '+88 016 4738 723',
      openTime: '10:00', // 10:00 AM
      closeTime: '21:30', // 9:30 PM
      avatarUrl:
      'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=800&auto=format&fit=crop',
    );

    // Dummy products
    products.assignAll(const [
      ProductItem(
        id: 'p1',
        title: 'Gaming Keyboard',
        price: 20,
        image:
        'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=800&auto=format&fit=crop',
      ),
      ProductItem(
        id: 'p2',
        title: 'Gaming Mouse',
        price: 20,
        image:
        'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?q=80&w=800&auto=format&fit=crop',
      ),
      ProductItem(
        id: 'p3',
        title: 'Keyboard',
        price: 20,
        image:
        'https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=800&auto=format&fit=crop',
      ),
      ProductItem(
        id: 'p4',
        title: 'Mouse',
        price: 20,
        image:
        'https://images.unsplash.com/photo-1516245834210-c4c142787335?q=80&w=800&auto=format&fit=crop',
      ),
      ProductItem(
        id: 'p5',
        title: 'Headset',
        price: 20,
        image:
        'https://images.unsplash.com/photo-1527430253228-e93688616381?q=80&w=800&auto=format&fit=crop',
      ),
      ProductItem(
        id: 'p6',
        title: 'Controller',
        price: 20,
        image:
        'https://images.unsplash.com/photo-1587300003388-59208cc962cb?q=80&w=800&auto=format&fit=crop',
      ),
    ]);
  }

  @override
  void onClose() {
    sheetCtrl.removeListener(_sheetListener);
    sheetCtrl.dispose();
    super.onClose();
  }

  // --- Private helpers ---
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
