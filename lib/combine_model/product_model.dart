class ProductItems {
  ProductItems({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    this.offerPrice,
    this.expiryBadges, // e.g. ['09','21','25']
  });
  final String id;
  final String title;
  final double price;
  final String image;
  final double? offerPrice;
  final List<String>? expiryBadges;
}