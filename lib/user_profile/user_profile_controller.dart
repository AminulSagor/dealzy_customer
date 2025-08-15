import 'package:get/get.dart';

class ProductItem {
  final String id;
  final String title;
  final String image; // asset path or URL
  final double price;

  const ProductItem({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
  });
}

class UserProfileController extends GetxController {
  // Dummy profile
  final name = 'Fouzia Hussain'.obs;
  final location = 'Jalalabad, Sylhet'.obs;
  final avatar = 'assets/png/searching_image.png'.obs; // replace with your asset

  // Dummy collection
  final RxList<ProductItem> collection = <ProductItem>[
    const ProductItem(
      id: '1',
      title: 'Gaming Keyboard',
      image: 'assets/png/mouse.jpg',
      price: 20,
    ),
    const ProductItem(
      id: '2',
      title: 'Gaming Mouse',
      image: 'assets/png/mouse.jpg',
      price: 20,
    ),
    const ProductItem(
      id: '3',
      title: 'Gaming Mouse',
      image: 'assets/png/mouse.jpg',
      price: 20,
    ),
  ].obs;

  void changeAvatar() {
    // TODO: open picker later
    Get.snackbar('Profile', 'Change photo tapped');
  }

  void openSettings() {
    Get.snackbar('Settings', 'Open settings tapped');
  }

  void openProduct(ProductItem p) {
    Get.snackbar('Product', p.title);
  }

  void removeFromCollection(ProductItem p) {
    collection.remove(p);
  }
}
