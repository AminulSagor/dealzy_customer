// models/product_details_models.dart
import 'package:meta/meta.dart';

@immutable
class ColorOption {
  final String id;
  final String color;
  const ColorOption({required this.id, required this.color});

  factory ColorOption.fromJson(Map<String, dynamic> j) =>
      ColorOption(id: j['id'] ?? '', color: j['color'] ?? '');
}

@immutable
class VariantOption {
  final String id;
  final String variant;
  const VariantOption({required this.id, required this.variant});

  factory VariantOption.fromJson(Map<String, dynamic> j) =>
      VariantOption(id: j['id'] ?? '', variant: j['variant'] ?? '');
}

/// Typed version of the API's "data" object plus computed helpers for the UI.
@immutable
class ProductDetailsData {
  final String id;
  final String name;
  final String model;
  final String brand;
  final double price;            // regular price from API
  final double? discountPrice;   // nullable
  final int stock;               // parsed int
  final String description;

  final String sellerId;
  final String categoryId;
  final String category;

  // Store info
  final String storeName;
  final String storeType;
  final String address;
  final String phone;

  final List<String> images;
  final List<ColorOption> colors;
  final List<VariantOption> variants;

  const ProductDetailsData({
    required this.id,
    required this.name,
    required this.model,
    required this.brand,
    required this.price,
    required this.discountPrice,
    required this.stock,
    required this.description,
    required this.sellerId,
    required this.categoryId,
    required this.category,
    required this.storeName,
    required this.storeType,
    required this.address,
    required this.phone,
    required this.images,
    required this.colors,
    required this.variants,
  });

  bool get hasDiscount => discountPrice != null && discountPrice! > 0;
  double get finalPrice => hasDiscount ? discountPrice! : price;
  String get availabilityText =>
      stock <= 0 ? 'Out of Stock' : '$stock in stock';

  // For your existing spec rows:
  String get colorOneLine =>
      colors.isEmpty ? '-' : colors.map((e) => e.color).join(', ');
  String get variantOneLine =>
      variants.isEmpty ? '-' : variants.map((e) => e.variant).join(', ');

  factory ProductDetailsData.fromApi(Map<String, dynamic> j) {
    double _toDouble(dynamic v) =>
        v == null || v.toString().isEmpty ? 0 : double.tryParse(v.toString()) ?? 0;
    int _toInt(dynamic v) =>
        v == null || v.toString().isEmpty ? 0 : int.tryParse(v.toString()) ?? 0;

    final imgs = (j['images'] as List? ?? [])
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    final cols = (j['colors'] as List? ?? [])
        .map((e) => ColorOption.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final vars = (j['variants'] as List? ?? [])
        .map((e) => VariantOption.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return ProductDetailsData(
      id: j['product_id']?.toString() ?? '',
      name: j['product_name']?.toString() ?? '',
      model: j['model']?.toString() ?? '-',
      brand: j['brand']?.toString() ?? '-',
      price: _toDouble(j['price']),
      discountPrice: j['discount_price'] == null
          ? null
          : _toDouble(j['discount_price']),
      stock: _toInt(j['stock']),
      description: j['description']?.toString() ?? '',
      sellerId: j['seller_id']?.toString() ?? '',
      categoryId: j['category_id']?.toString() ?? '',
      category: j['category']?.toString() ?? '-',
      storeName: j['store_name']?.toString() ?? '-',
      storeType: j['store_type']?.toString() ?? '-',
      address: j['address']?.toString() ?? '-',
      phone: j['phone']?.toString() ?? '-',
      images: imgs.isEmpty
          ? const ['https://via.placeholder.com/800x800?text=No+Image']
          : imgs,
      colors: cols,
      variants: vars,
    );
  }
}
