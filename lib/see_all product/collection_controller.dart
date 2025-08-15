import 'package:get/get.dart';

class CollectionItem {
  final String id;
  final String title;
  final double price;
  final String image; // asset or url
  const CollectionItem({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
  });
}

class CollectionController extends GetxController {
  // Dummy grid data (mix of assets/urls ok)
  final RxList<CollectionItem> items = <CollectionItem>[
    const CollectionItem(
      id: '1', title: 'Gaming Keyboard', price: 20,
      image: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800',
    ),
    const CollectionItem(
      id: '2', title: 'Gaming Mouse', price: 20,
      image: 'https://images.unsplash.com/photo-1585079542156-2755d9c8a094?w=800',
    ),
    const CollectionItem(
      id: '3', title: 'Gaming Keyboard', price: 20,
      image: 'https://images.unsplash.com/photo-1518779578993-ec3579fee39f?w=800',
    ),
    const CollectionItem(
      id: '4', title: 'Gaming Mouse', price: 20,
      image: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800',
    ),
    const CollectionItem(
      id: '5', title: 'Gaming Keyboard', price: 20,
      image: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800',
    ),
    const CollectionItem(
      id: '6', title: 'Gaming Mouse', price: 20,
      image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
    ),
    const CollectionItem(
      id: '7', title: 'Gaming Mouse', price: 20,
      image: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800',
    ),
    const CollectionItem(
      id: '8', title: 'Gaming Keyboard', price: 20,
      image: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800',
    ),
    const CollectionItem(
      id: '9', title: 'Gaming Mouse', price: 20,
      image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
    ),
  ].obs;

  void back() => Get.back();

  void openMenu() => Get.snackbar('Menu', 'More options tapped');

  void openItem(CollectionItem i) => Get.snackbar('Open', i.title);

  void addToCollection(CollectionItem i) =>
      Get.snackbar('Added', '${i.title} added');
}
