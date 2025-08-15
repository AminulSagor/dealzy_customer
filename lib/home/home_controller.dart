import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryItem {
  CategoryItem({required this.name, required this.image});
  final String name;
  final String image;
}

class BannerItem {
  BannerItem({required this.image, required this.title, required this.subtitle});
  final String image;
  final String title;
  final String subtitle;
}

class ProductItem {
  ProductItem({
    required this.title,
    required this.price,
    required this.image,
    this.offerPrice,
    this.expiryBadges, // e.g. ['09','21','25']
  });

  final String title;
  final double price;
  final String image;
  final double? offerPrice;
  final List<String>? expiryBadges;
}

class HomeController extends GetxController {
  static const blue = Color(0xFF124A89);

  // user header
  final username = 'uiuxzia';
  final location = 'Jalalabad,Sylhet';

  // search
  final searchCtrl = TextEditingController();

  // banner
  final bannerCtrl = PageController();
  final currentBanner = 0.obs;

  // data
  final categories = <CategoryItem>[].obs;
  final banners = <BannerItem>[].obs;

  final regularProducts = <ProductItem>[].obs;
  final expiringProducts = <ProductItem>[].obs;
  final clearanceProducts = <ProductItem>[].obs;

  // nav
  final navIndex = 0.obs;

  // actions
  void onTapFilter() => Get.snackbar('Filter', 'Open filters…',
      snackPosition: SnackPosition.BOTTOM);
  void onTapSeeAll(String section) =>
      Get.snackbar('See All', 'Open "$section"', snackPosition: SnackPosition.BOTTOM);
  void onAdd(ProductItem p) =>
      Get.snackbar('Added', '${p.title} added', snackPosition: SnackPosition.BOTTOM);
  void onOpen(ProductItem p) => Get.snackbar('Open', p.title,
      snackPosition: SnackPosition.BOTTOM);

  @override
  void onInit() {
    super.onInit();

    categories.assignAll([
      CategoryItem(
          name: 'Watch',
          image:
          'https://images.unsplash.com/photo-1524805444758-089113d48a6d?q=80&w=300&auto=format&fit=crop'),
      CategoryItem(
          name: 'Clothing',
          image:
          'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?q=80&w=300&auto=format&fit=crop'),
      CategoryItem(
          name: 'Face',
          image:
          'https://images.unsplash.com/photo-1545912452-8aea7e25a3d3?q=80&w=300&auto=format&fit=crop'),
      CategoryItem(
          name: 'Electrical',
          image:
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=300&auto=format&fit=crop'),
      CategoryItem(
          name: 'Shoes',
          image:
          'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?q=80&w=300&auto=format&fit=crop'),
    ]);

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
      BannerItem(
        image:
        'https://images.unsplash.com/photo-1519744792095-2f2205e87b6f?q=80&w=1200&auto=format&fit=crop',
        title: 'Smart Gadgets',
        subtitle: 'Latest tech and accessories.',
      ),
    ]);

    regularProducts.assignAll([
      ProductItem(
        title: 'Gaming Keyboard',
        price: 20,
        image:
        'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=800&auto=format&fit=crop',
      ),
      ProductItem(
        title: 'Gaming Mouse',
        price: 20,
        image:
        'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?q=80&w=800&auto=format&fit=crop',
      ),
      ProductItem(
        title: 'Headset',
        price: 20,
        image:
        'https://images.unsplash.com/photo-1527430253228-e93688616381?q=80&w=800&auto=format&fit=crop',
      ),
    ]);

    expiringProducts.assignAll([
      ProductItem(
        title: 'Fresh Tomatoes',
        price: 20,
        offerPrice: 15,
        image:
        'https://images.unsplash.com/photo-1506806732259-39c2d0268443?q=80&w=800&auto=format&fit=crop',
        expiryBadges: ['09', '21', '25'],
      ),
      ProductItem(
        title: 'Potatoes',
        price: 20,
        offerPrice: 15,
        image:
        'https://images.unsplash.com/photo-1518977676601-b53f82aba655?q=80&w=800&auto=format&fit=crop',
        expiryBadges: ['09', '21', '25'],
      ),
    ]);

    clearanceProducts.assignAll([
      ProductItem(
        title: 'Running Shoe',
        price: 20,
        image:
        'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?q=80&w=800&auto=format&fit=crop',
      ),
      ProductItem(
        title: 'Sneaker',
        price: 20,
        image:
        'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=800&auto=format&fit=crop',
      ),
    ]);

    bannerCtrl.addListener(() {
      currentBanner.value = (bannerCtrl.page ?? 0).round();
    });
  }

  @override
  void onClose() {
    bannerCtrl.dispose();
    searchCtrl.dispose();
    super.onClose();
  }
}
