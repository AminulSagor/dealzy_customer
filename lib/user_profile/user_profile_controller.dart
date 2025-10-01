import 'package:dealzy/user_profile/user_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dealzy/widgets/login_required_dialog.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../routes/app_routes.dart';

class ProductItem {
  final String id;
  final String title;
  final String image; // asset path or URL
  final double price;
  final double? offerPrice;

  const ProductItem({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    this.offerPrice,
  });

  factory ProductItem.fromBookmarked(BookmarkedProduct b) => ProductItem(
    id: b.productId,
    title: b.productName,
    image: b.imagePath,
    price: b.price,
    offerPrice: b.offerPrice,
  );
}

class UserProfileController extends GetxController {
  UserProfileController({UserProfileService? service})
      : _service = service ?? UserProfileService();

  final UserProfileService _service;

  // Profile (reactive; start with sensible defaults)
  final name = '—'.obs;
  final location = '—'.obs;
  final avatar = ''.obs;

  // Collection: bookmarks from API
  final RxList<ProductItem> collection = <ProductItem>[].obs;

  // Paging + states
  final isLoading = false.obs;
  final error = RxnString();
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final pageSize = 10.obs;
  final isLoadingMore = false.obs;
  final isUploadingAvatar = false.obs;


  // Horizontal list scroll controller for pagination
  final ScrollController collectionCtrl = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
    fetchFirstPage();
    collectionCtrl.addListener(_onCollectionScroll);
  }

  @override
  void onClose() {
    collectionCtrl.removeListener(_onCollectionScroll);
    collectionCtrl.dispose();
    super.onClose();
  }

  void _onCollectionScroll() {
    if (!collectionCtrl.hasClients) return;
    final pos = collectionCtrl.position;
    const threshold = 120.0; // px before the end to trigger next page
    if (pos.pixels >= pos.maxScrollExtent - threshold && !isLoadingMore.value) {
      loadMore();
    }
  }

  Future<void> _loadProfile() async {
    try {
      final p = await _service.fetchUserProfile();

      name.value = p.name.isNotEmpty ? p.name : '—';

      // Compose location "AdminDistrict, PostCode" when available
      final hasAdmin = p.adminDistrict.trim().isNotEmpty;
      final hasPost = p.postCode.trim().isNotEmpty;
      location.value = hasAdmin && hasPost
          ? '${p.adminDistrict}, ${p.postCode}'
          : (hasAdmin ? p.adminDistrict : (hasPost ? p.postCode : '—'));

      if (p.imagePath.trim().isNotEmpty) {
        avatar.value = p.imagePath; // network image
      }
    } on StateError catch (e) {
      // Missing token or base URL; surface login dialog for auth case
      if (e.message.contains('Missing token')) {
        Get.dialog(const LoginRequiredDialog(), barrierDismissible: false);
      } else {
        error.value = e.message;
      }
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> fetchFirstPage({int limit = 10}) async {
    isLoading.value = true;
    error.value = null;
    collection.clear();
    currentPage.value = 1;
    pageSize.value = limit;

    try {
      final res = await _service.fetchBookmarkedProducts(page: 1, limit: limit);
      totalPages.value = res.totalPages;

      final mapped = res.data.map(ProductItem.fromBookmarked).toList();
      collection.assignAll(mapped);
    } on StateError catch (e) {
      error.value = e.message;
      collection.clear();
    } catch (e) {
      error.value = e.toString();
      collection.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value) return;
    if (currentPage.value >= totalPages.value) return;

    isLoadingMore.value = true;
    try {
      final next = currentPage.value + 1;
      final res =
      await _service.fetchBookmarkedProducts(page: next, limit: pageSize.value);
      currentPage.value = res.currentPage;
      totalPages.value = res.totalPages;

      final mapped = res.data.map(ProductItem.fromBookmarked).toList();
      collection.addAll(mapped);
    } catch (_) {
      // Optionally surface a transient error/snackbar
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ---- UI callbacks ----
  Future<void> changeAvatar() async {
    try {
      final picker = ImagePicker();
      // Gallery; compress to keep payload small
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,         // keep good quality, smaller file
        imageQuality: 85,       // JPEG compression on Android/iOS
      );
      if (picked == null) return;

      isUploadingAvatar.value = true;

      final url = await _service.uploadProfileImage(File(picked.path));
      avatar.value = url; // update UI immediately

      Get.rawSnackbar(
        messageText: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('Profile picture updated', style: TextStyle(color: Colors.white))),
          ],
        ),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 2),
      );
    } on StateError catch (e) {
      if (e.message.contains('Missing token')) {
        Get.dialog(const LoginRequiredDialog(), barrierDismissible: false);
      } else {
        Get.snackbar('Upload failed', e.message,
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade200);
      }
    } catch (e) {
      Get.snackbar('Upload failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade200);
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  void openSettings() {
    Get.toNamed(AppRoutes.appSetting);
  }


  void openProduct(ProductItem p) {
    Get.toNamed('/product-details', parameters: {'id': p.id});
  }

  // lib/user_profile/user_profile_controller.dart
  Future<void> removeFromCollection(ProductItem p) async {
    final index = collection.indexOf(p); // keep position for undo
    try {
      await _service.removeBookmark(p.id);
      collection.removeAt(index);

      Get.rawSnackbar(
        messageText: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('Removed “${p.title}”', style: const TextStyle(color: Colors.white))),

          ],
        ),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 3),
      );
    } on StateError catch (e) {
      if (e.message.contains('Missing token')) {
        Get.dialog(const LoginRequiredDialog(), barrierDismissible: false);
      } else {
        Get.snackbar('Error', e.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade200);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade200);
    }
  }

}
