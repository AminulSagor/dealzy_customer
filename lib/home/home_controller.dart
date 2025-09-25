// lib/home/home_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../combine_model/product_model.dart';
import '../combine_service/bookmark_service.dart';
import '../routes/app_routes.dart';
import '../widgets/login_required_dialog.dart';
import 'home_service.dart';
import 'home_products_model.dart';
import '../user_profile/user_profile_service.dart'; // <-- reuse the existing service

// ----------------- UI Models -----------------
class CategoryItem {
  CategoryItem({
    required this.id,
    required this.name,
    required this.image,
  });

  final String id;
  final String name;
  final String image;
}

class BannerItem {
  BannerItem({
    required this.image,
    this.title,
    this.subtitle,
  });
  final String image;
  final String? title;
  final String? subtitle;
}

// ----------------- Controller -----------------
class HomeController extends GetxController {
  HomeController({HomeService? service, UserProfileService? profileService})
      : _service = service ?? HomeService(),
        _profileService = profileService ?? UserProfileService();

  static const blue = Color(0xFF124A89);

  // Services
  final HomeService _service;
  final UserProfileService _profileService;
  final BookmarkService _bookmarkService = BookmarkService();

  // ---- Header (reactive, will be overridden by profile if available) ----
  final username = ''.obs;
  final location = 'Jalalabad,Sylhet'.obs;
  final avatarUrl = ''.obs;

  // search
  final searchCtrl = TextEditingController();

  // banner
  final bannerCtrl = PageController();
  final currentBanner = 0.obs;

  // data
  final categories = <CategoryItem>[].obs;
  final banners = <BannerItem>[].obs;

  // products per section
  final regularProducts = <ProductItems>[].obs;
  final expiringProducts = <ProductItems>[].obs;
  final clearanceProducts = <ProductItems>[].obs;

  // NEW: Seasonal & Service Special
  final seasonalProducts = <ProductItems>[].obs;
  final serviceSpecialProducts = <ProductItems>[].obs;

  final _bookmarking = <String>{}.obs;

  // ---------- States ----------
  // categories
  final isLoadingCategories = false.obs;
  final categoriesError = RxnString();

  // sliders
  final isLoadingBanners = false.obs;
  final bannersError = RxnString();

  // products per section
  final isLoadingRegular = false.obs;
  final regularError = RxnString();

  final isLoadingExpiring = false.obs;
  final expiringError = RxnString();

  final isLoadingClearance = false.obs;
  final clearanceError = RxnString();

  // NEW: loading + error for Seasonal & Service Special
  final isLoadingSeasonal = false.obs;
  final seasonalError = RxnString();

  final isLoadingServiceSpecial = false.obs;
  final serviceSpecialError = RxnString();

  // paging (prepared for "See All" / infinite scroll later)
  int _regularPage = 1;
  int _expiringPage = 1;
  int _clearancePage = 1;

  // NEW: pages for Seasonal & Service Special
  int _seasonalPage = 1;
  int _serviceSpecialPage = 1;

  final int _limit = 10;

  // --- AUTOPLAY ---
  Timer? _autoTimer;
  final autoInterval = const Duration(seconds: 4);
  final autoAnimDuration = const Duration(milliseconds: 450);
  final autoCurve = Curves.easeOutCubic;
  var _userDragging = false;

  bool get _canSlide => bannerCtrl.hasClients && banners.isNotEmpty;
  bool isBookmarking(String productId) => _bookmarking.contains(productId);

  void pauseAutoPlay() => _userDragging = true;
  void resumeAutoPlay() => _userDragging = false;

  void startAutoPlay() {
    _autoTimer?.cancel();
    if (!_canSlide) return;
    _autoTimer = Timer.periodic(autoInterval, (_) {
      if (_userDragging || !_canSlide) return;
      final next = (currentBanner.value + 1) % banners.length;
      bannerCtrl.animateToPage(next, duration: autoAnimDuration, curve: autoCurve);
    });
  }

  void stopAutoPlay() {
    _autoTimer?.cancel();
    _autoTimer = null;
  }

  void _startAutoWhenAttached() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_canSlide) {
        final safeIndex = (currentBanner.value >= banners.length) ? 0 : currentBanner.value;
        if (safeIndex != currentBanner.value) currentBanner.value = 0;
        if (bannerCtrl.hasClients) {
          try { bannerCtrl.jumpToPage(safeIndex); } catch (_) {}
        }
        startAutoPlay();
      } else {
        Future.delayed(const Duration(milliseconds: 120), () {
          if (_canSlide) startAutoPlay();
        });
      }
    });
  }
  // --- AUTOPLAY end ---

  // expose refreshers to UI (if you need pull-to-refresh)
  Future<void> refreshCategories() => _loadCategories();
  Future<void> refreshBanners() => _loadSliders();
  Future<void> refreshRegular() => _loadRegular(resetPage: true);
  Future<void> refreshExpiring() => _loadExpiring(resetPage: true);
  Future<void> refreshClearance() => _loadClearance(resetPage: true);

  // NEW: refreshers
  Future<void> refreshSeasonal() => _loadSeasonal(resetPage: true);
  Future<void> refreshServiceSpecial() => _loadServiceSpecial(resetPage: true);

  // nav
  final navIndex = 0.obs;

  // actions
  void onTapFilter() =>
      Get.snackbar('Filter', 'Open filters…', snackPosition: SnackPosition.BOTTOM);

  void onTapSeeAll(String section) {
    // map UI section to API offer key
    String? offer;
    switch (section.trim().toLowerCase()) {
      case 'regular offer':
        offer = 'regular';
        break;
      case 'expiring offer':
        offer = 'expiring_soon';
        break;
      case 'clearance offer':
        offer = 'clearance';
        break;
    // NEW:
      case 'seasonal offer':
        offer = 'seasonal';
        break;
      case 'service special offer':
        offer = 'service_special';
        break;
    }

    if (offer == null) {
      Get.snackbar('See All', 'Unknown section "$section"',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.toNamed(
      AppRoutes.collection,
      arguments: {
        'offer': offer,             // <- important
        'title': section,           // nice-to-have for app bar
        'fromHome': false,
      },
    );
  }

  void onOpen(ProductItems item) {
    Get.toNamed('/product-details/${item.id}');
  }

  Future<void> onBookmark(ProductItems item) async {
    final id = item.id.toString();
    if (_bookmarking.contains(id)) return;
    _bookmarking.add(id);

    try {
      final res = await _bookmarkService.bookmarkProduct(id);
      Get.snackbar(
        'Saved',
        res.message.isNotEmpty ? res.message : 'Bookmarked "${item.title}"',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );
    } on StateError catch (e) {
      if (e.message.contains('Missing token')) {
        Get.dialog(const LoginRequiredDialog(), barrierDismissible: false);
      } else {
        Get.snackbar('Error', e.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFEF6C00),
            colorText: Colors.white,
            margin: const EdgeInsets.all(12));
      }
    } catch (e) {
      Get.snackbar('Bookmark failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFD32F2F),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12));
    } finally {
      _bookmarking.remove(id);
    }
  }

  @override
  void onInit() {
    super.onInit();

    _seedBanners(); // optional placeholder banners
    _loadProfileThenData(); // <-- load profile first; data loaders below can use location later if needed

    // keep dot indicator in sync
    bannerCtrl.addListener(() {
      final page = bannerCtrl.page;
      if (page != null) currentBanner.value = page.round();
    });

    _startAutoWhenAttached();
  }

  Future<void> _loadProfileThenData() async {
    await _loadProfile(); // safely sets username/location/avatar if available

    // Load visual data after profile
    _loadCategories();
    _loadSliders();
    _loadRegular(resetPage: true);
    _loadExpiring(resetPage: true);
    _loadClearance(resetPage: true);

    // NEW:
    _loadSeasonal(resetPage: true);
    _loadServiceSpecial(resetPage: true);
  }

  /// Fetch profile; if location is available, override the header.
  Future<void> _loadProfile() async {
    try {
      final p = await _profileService.fetchUserProfile();

      if (p.name.trim().isNotEmpty) {
        username.value = p.name.trim();
      }

      final admin = p.adminDistrict.trim();
      final post = p.postCode.trim();
      final composed = (admin.isNotEmpty && post.isNotEmpty)
          ? '$admin,$post'
          : (admin.isNotEmpty ? admin : (post.isNotEmpty ? post : ''));

      if (composed.isNotEmpty) {
        location.value = composed;
      }

      if (p.imagePath.trim().isNotEmpty) {
        avatarUrl.value = p.imagePath.trim();
      }
    } on StateError catch (e) {
      if (e.message.contains('Missing token')) {
        // Get.dialog(const LoginRequiredDialog(), barrierDismissible: false);
      }
    } catch (_) {
      // ignore, keep defaults
    }
  }

  // ---------- Categories ----------
  Future<void> _loadCategories() async {
    isLoadingCategories.value = true;
    categoriesError.value = null;

    try {
      final apiCats = await _service.getAllCategories();
      categories.assignAll(
        apiCats.map((c) => CategoryItem(
          id: c.id.toString(),
          name: c.category,
          image: c.imgPath,
        )),
      );
    } catch (e) {
      categoriesError.value = e.toString();
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // ---------- Sliders ----------
  Future<void> _loadSliders() async {
    isLoadingBanners.value = true;
    bannersError.value = null;
    stopAutoPlay();

    try {
      final apiSliders = await _service.getAllSliders();
      final mapped = apiSliders
          .where((s) => s.imageUrl.isNotEmpty)
          .map((s) => BannerItem(image: s.imageUrl))
          .toList();

      banners.assignAll(mapped);
      currentBanner.value = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (bannerCtrl.hasClients && banners.isNotEmpty) {
          try { bannerCtrl.jumpToPage(0); } catch (_) {}
        }
        _startAutoWhenAttached();
      });
    } catch (e) {
      bannersError.value = e.toString();
      _startAutoWhenAttached();
    } finally {
      isLoadingBanners.value = false;
    }
  }

  // ---------- Products ----------
  Future<void> _loadRegular({bool resetPage = false}) async {
    if (resetPage) _regularPage = 1;
    isLoadingRegular.value = true;
    regularError.value = null;
    try {
      final res = await _service.getHomeProducts(
        offer: 'regular',
        page: _regularPage,
        limit: _limit,
      );
      final items = res.products.map(_mapDtoToProduct).toList();
      if (resetPage) {
        regularProducts.assignAll(items);
      } else {
        regularProducts.addAll(items);
      }
    } catch (e) {
      regularError.value = e.toString();
    } finally {
      isLoadingRegular.value = false;
    }
  }

  Future<void> _loadExpiring({bool resetPage = false}) async {
    if (resetPage) _expiringPage = 1;
    isLoadingExpiring.value = true;
    expiringError.value = null;
    try {
      final res = await _service.getHomeProducts(
        offer: 'expiring_soon',
        page: _expiringPage,
        limit: _limit,
      );
      final items = res.products
          .map((p) => _mapDtoToProduct(p, expiring: true))
          .toList();

      if (resetPage) {
        expiringProducts.assignAll(items);
      } else {
        expiringProducts.addAll(items);
      }
    } catch (e) {
      expiringError.value = e.toString();
    } finally {
      isLoadingExpiring.value = false;
    }
  }

  Future<void> _loadClearance({bool resetPage = false}) async {
    if (resetPage) _clearancePage = 1;
    isLoadingClearance.value = true;
    clearanceError.value = null;
    try {
      final res = await _service.getHomeProducts(
        offer: 'clearance',
        page: _clearancePage,
        limit: _limit,
      );
      final items = res.products.map(_mapDtoToProduct).toList();
      if (resetPage) {
        clearanceProducts.assignAll(items);
      } else {
        clearanceProducts.addAll(items);
      }
    } catch (e) {
      clearanceError.value = e.toString();
    } finally {
      isLoadingClearance.value = false;
    }
  }

  // NEW: Seasonal (design like Expiring → set expiring: true for badges/skin)
  Future<void> _loadSeasonal({bool resetPage = false}) async {
    if (resetPage) _seasonalPage = 1;
    isLoadingSeasonal.value = true;
    seasonalError.value = null;
    try {
      final res = await _service.getHomeProducts(
        offer: 'seasonal',
        page: _seasonalPage,
        limit: _limit,
      );
      final items = res.products
          .map((p) => _mapDtoToProduct(p, expiring: true)) // ← reuse expiring badge logic
          .toList();

      if (resetPage) {
        seasonalProducts.assignAll(items);
      } else {
        seasonalProducts.addAll(items);
      }
    } catch (e) {
      seasonalError.value = e.toString();
    } finally {
      isLoadingSeasonal.value = false;
    }
  }

  // NEW: Service Special (design like Regular/Clearance → expiring: false)
  Future<void> _loadServiceSpecial({bool resetPage = false}) async {
    if (resetPage) _serviceSpecialPage = 1;
    isLoadingServiceSpecial.value = true;
    serviceSpecialError.value = null;
    try {
      final res = await _service.getHomeProducts(
        offer: 'service_special',
        page: _serviceSpecialPage,
        limit: _limit,
      );
      final items = res.products.map(_mapDtoToProduct).toList();

      if (resetPage) {
        serviceSpecialProducts.assignAll(items);
      } else {
        serviceSpecialProducts.addAll(items);
      }
    } catch (e) {
      serviceSpecialError.value = e.toString();
    } finally {
      isLoadingServiceSpecial.value = false;
    }
  }

  ProductItems _mapDtoToProduct(HomeProductDto p, {bool expiring = false}) {
    double _toDouble(String? s) => double.tryParse((s ?? '').trim()) ?? 0.0;

    List<String>? badges;
    if (expiring && (p.expiryDate != null && p.expiryDate!.isNotEmpty)) {
      final dt = DateTime.tryParse(p.expiryDate!);
      if (dt != null) {
        final mm = dt.month.toString().padLeft(2, '0');
        final dd = dt.day.toString().padLeft(2, '0');
        final yy = (dt.year % 100).toString().padLeft(2, '0');
        badges = [mm, dd, yy];
      }
    }

    return ProductItems(
      id: p.id.toString(),
      title: p.name,
      price: _toDouble(p.price),
      image: p.imagePath,
      offerPrice: (p.offerPrice == null || p.offerPrice!.isEmpty)
          ? null
          : _toDouble(p.offerPrice),
      expiryBadges: badges,
    );
  }

  // ---------- Seeds (optional) ----------
  void _seedBanners() {
    banners.assignAll([
      BannerItem(
        image:
        'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=1200&auto=format&fit=crop',
        title: 'New Collection',
        subtitle:
        'Lorem ipsum is simply dummy text of the printing and typesetting industry.',
      ),
      BannerItem(
        image:
        'https://images.unsplash.com/photo-1520975916090-3105956dac38?q=80&w=1200&auto=format&fit=crop',
        title: 'Summer Sale',
        subtitle: 'Up to 50% off on selected items.',
      ),
    ]);
  }

  @override
  void onClose() {
    stopAutoPlay();
    bannerCtrl.dispose();
    searchCtrl.dispose();
    _service.dispose();
    super.onClose();
  }
}
