class ProductItem {
  const ProductItem({
    required this.id,
    required this.title,
    required this.price,
    this.offerPrice,
    required this.image,
  });

  final String id;
  final String title;
  final double price;
  final double? offerPrice;
  final String image;

  /// Factory to parse API JSON
  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['product_id']?.toString() ?? '',
      title: json['product_name']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      offerPrice: (json['offer_price'] == null ||
          json['offer_price'].toString().isEmpty)
          ? null
          : double.tryParse(json['offer_price'].toString()),
      image: json['image_path']?.toString() ?? '',
    );
  }
}
