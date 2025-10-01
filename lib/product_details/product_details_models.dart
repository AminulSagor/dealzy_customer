import 'package:meta/meta.dart';

@immutable
class ColorOption {
  final String id;
  final String color;
  const ColorOption({required this.id, required this.color});

  factory ColorOption.fromJson(Map<String, dynamic> j) =>
      ColorOption(id: (j['id'] ?? '').toString(), color: (j['color'] ?? '').toString());
}

@immutable
class VariantOption {
  final String id;
  final String variant;
  const VariantOption({required this.id, required this.variant});

  factory VariantOption.fromJson(Map<String, dynamic> j) =>
      VariantOption(id: (j['id'] ?? '').toString(), variant: (j['variant'] ?? '').toString());
}

/// Typed version of the API's "data" object plus computed helpers for the UI.
@immutable
class ProductDetailsData {
  final String id;
  final String name;
  final String model;
  final String brand;


  /// Regular price from API
  final double price;

  /// Nullable discount price
  final double? discountPrice;

  /// Parsed stock as int
  final int stock;

  final String description;

  /// Store / seller references
  final String sellerId;
  final String categoryId;
  final String category;

  /// Store info
  final String storeName;
  final String storeType;
  final String address;
  final String phone;

  /// Business hours (raw from API, e.g. "22:56:00")
  final String? openingTime;  // maps from `opening_time`
  final String? closingTime;  // maps from `closing_time`
  final String? proPath;


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
    this.openingTime,
    this.closingTime,
    this.proPath,

  });

  // ---------- Computed helpers ----------

  bool get hasDiscount => discountPrice != null && discountPrice! > 0;
  double get finalPrice => hasDiscount ? discountPrice! : price;

  String get availabilityText => stock <= 0 ? 'Out of Stock' : '$stock in stock';

  /// For your existing spec rows:
  String get colorOneLine =>
      colors.isEmpty ? '-' : colors.map((e) => e.color).join(', ');
  String get variantOneLine =>
      variants.isEmpty ? '-' : variants.map((e) => e.variant).join(', ');

  /// True if both opening/closing exist (even if not normalized)
  bool get hasHours =>
      (openingTime != null && openingTime!.trim().isNotEmpty) &&
          (closingTime != null && closingTime!.trim().isNotEmpty);

  /// Convenience: normalize to "HH:mm" (e.g. "22:56:00" -> "22:56")
  String get openingTimeHHmm => _toHHmm(openingTime);
  String get closingTimeHHmm => _toHHmm(closingTime);

  // ---------- Factory ----------

  /// Accepts either the inner `data` object or a flattened map.
  factory ProductDetailsData.fromApi(Map<String, dynamic> j) {
    // Some APIs return {status, data:{...}} – handle both.
    final d = (j['data'] is Map<String, dynamic>) ? (j['data'] as Map<String, dynamic>) : j;

    double _toDouble(dynamic v) =>
        v == null || v.toString().trim().isEmpty ? 0 : double.tryParse(v.toString()) ?? 0;

    int _toInt(dynamic v) =>
        v == null || v.toString().trim().isEmpty ? 0 : int.tryParse(v.toString()) ?? 0;

    final imgs = (d['images'] as List? ?? [])
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    final cols = (d['colors'] as List? ?? [])
        .map((e) => ColorOption.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final vars = (d['variants'] as List? ?? [])
        .map((e) => VariantOption.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    // Allow both opening_time/closing_time (preferred) and a couple of fallbacks.
    final String? opening = (d['opening_time'] ?? d['open_time'] ?? d['opening']) as String?;
    final String? closing = (d['closing_time'] ?? d['close_time'] ?? d['closing']) as String?;

    return ProductDetailsData(
      id:         d['product_id']?.toString() ?? '',
      name:       d['product_name']?.toString() ?? '',
      model:      d['model']?.toString() ?? '-',
      brand:      d['brand']?.toString() ?? '-',
      price:      _toDouble(d['price']),
      discountPrice: d['discount_price'] == null ? null : _toDouble(d['discount_price']),
      stock:      _toInt(d['stock']),
      description: d['description']?.toString() ?? '',
      sellerId:   d['seller_id']?.toString() ?? '',
      categoryId: d['category_id']?.toString() ?? '',
      category:   d['category']?.toString() ?? '-',
      storeName:  d['store_name']?.toString() ?? '-',
      storeType:  d['store_type']?.toString() ?? '-',
      address:    d['address']?.toString() ?? '-',
      phone:      d['phone']?.toString() ?? '-',
      images: imgs.isEmpty ? [] : imgs,
      colors:     cols,
      variants:   vars,
      openingTime: opening?.trim(),
      closingTime: closing?.trim(),
      proPath: (d['pro_path'] ?? '').toString(),

    );
  }

  // ---------- Private helpers ----------

  static String _toHHmm(String? raw) {
    final t = (raw ?? '').trim();
    if (t.isEmpty) return ''; // safe fallback if API missing
    final parts = t.split(':');
    final h = int.tryParse(parts[0]) ?? 10;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final hh = h.clamp(0, 23).toString().padLeft(2, '0');
    final mm = m.clamp(0, 59).toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
