import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreItem {
  final String id;
  final String name;
  final String category;
  final String phone;
  final String logo; // asset path or URL

  StoreItem({
    required this.id,
    required this.name,
    required this.category,
    required this.phone,
    required this.logo,
  });
}

class StoreSearchController extends GetxController {
  final queryCtrl = TextEditingController();

  /// full set (dummy for now)
  final List<StoreItem> _all = <StoreItem>[
    StoreItem(
      id: '1',
      name: 'Fashion.Hube',
      category: 'Clothing',
      phone: '+88 015 4834444',
      logo: 'assets/png/searching_image.png',
    ),
    StoreItem(
      id: '2',
      name: 'Amazon',
      category: 'Clothing',
      phone: '+88 015 4834444',
      logo: 'assets/png/searching_image.png',
    ),
    StoreItem(
      id: '3',
      name: 'ICON',
      category: 'Clothing',
      phone: '+88 015 4834444',
      logo: 'assets/png/searching_image.png',
    ),
    StoreItem(
      id: '4',
      name: 'Freedom',
      category: 'Clothing',
      phone: '+88 015 4834444',
      logo: 'assets/png/searching_image.png', // shown in your screenshot
    ),
  ];

  /// observable list used by UI
  final RxList<StoreItem> stores = <StoreItem>[].obs;
  final RxBool loading = false.obs;

  Timer? _debouncer;

  @override
  void onInit() {
    super.onInit();
    // initial fill
    stores.assignAll(_all);
    // listen & debounce search
    queryCtrl.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    _debouncer?.cancel();
    _debouncer = Timer(const Duration(milliseconds: 300), _applyFilter);
  }

  void _applyFilter() {
    final q = queryCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      stores.assignAll(_all);
      return;
    }
    stores.assignAll(
      _all.where((s) =>
      s.name.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q)),
    );
  }

  void openFilters() {
    Get.snackbar('Filters', 'Filter sheet coming soon');
  }

  void openStore(StoreItem s) {
    Get.snackbar('View', s.name);
  }

  @override
  void onClose() {
    queryCtrl.dispose();
    _debouncer?.cancel();
    super.onClose();
  }
}
