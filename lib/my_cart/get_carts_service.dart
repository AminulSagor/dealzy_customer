import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:dealzy/storage/token_storage.dart';

typedef TokenProvider = Future<String?> Function();

/// ─────────────────────────────────────────
/// 🟩 MODELS
/// ─────────────────────────────────────────

class ProductColor {
  final String id;
  final String color;

  const ProductColor({required this.id, required this.color});

  factory ProductColor.fromJson(Map<String, dynamic> j) => ProductColor(
    id: j['id'].toString(),
    color: (j['color'] ?? '').toString(),
  );
}

class ProductVariant {
  final String id;
  final String variant;

  const ProductVariant({required this.id, required this.variant});

  factory ProductVariant.fromJson(Map<String, dynamic> j) => ProductVariant(
    id: j['id'].toString(),
    variant: (j['variant'] ?? '').toString(),
  );
}

class CartItem {
  final String cartId;
  final String productId;
  final String? discount;
  final String? expiryDate;
  final String productName;
  final String? model;
  final String? brand;
  final double price;
  final int stock;
  final String imagePath;

  /// Reactive states
  RxBool isSelected = false.obs;
  RxInt quantity = 1.obs;

  /// Available options
  List<ProductColor> colors = [];
  List<ProductVariant> variants = [];

  /// Selected options
  Rxn<ProductColor> selectedColor = Rxn<ProductColor>();
  Rxn<ProductVariant> selectedVariant = Rxn<ProductVariant>();

  CartItem({
    required this.cartId,
    required this.productId,
    this.discount,
    this.expiryDate,
    required this.productName,
    this.model,
    this.brand,
    required this.price,
    required this.stock,
    required this.imagePath,
  });

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
    cartId: j['cart_id'].toString(),
    productId: j['product_id'].toString(),
    discount: j['discount'],
    expiryDate: j['expiry_date'],
    productName: (j['product_name'] ?? '').toString(),
    model: j['model']?.toString(),
    brand: j['brand']?.toString(),
    price: double.tryParse(j['price'].toString()) ?? 0.0,
    stock: int.tryParse(j['stock'].toString()) ?? 0,
    imagePath: (j['image_path'] ?? '').toString(),
  );

  bool get isAvailable => stock >= quantity.value;
}

class SellerInfo {
  final String sellerId;
  final String storeName;
  final String address;
  final String openingTime;
  final String closingTime;
  final String profilePath;
  final String latitude;
  final String longitude;

  const SellerInfo({
    required this.sellerId,
    required this.storeName,
    required this.address,
    required this.openingTime,
    required this.closingTime,
    required this.profilePath,
    required this.latitude,
    required this.longitude,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> j) => SellerInfo(
    sellerId: (j['seller_id'] ?? '').toString(),
    storeName: (j['store_name'] ?? '').toString(),
    address: (j['address'] ?? '').toString(),
    openingTime: (j['opening_time'] ?? '').toString(),
    closingTime: (j['closing_time'] ?? '').toString(),
    profilePath: (j['pro_path'] ?? '').toString(),
    latitude: (j['latitude'] ?? '').toString(),
    longitude: (j['longitude'] ?? '').toString(),
  );
}

class GetCartResponse {
  final String status;
  final int availableCoins;
  final int minimumUse;
  final SellerInfo? seller;
  final List<CartItem> carts;

  const GetCartResponse({
    required this.status,
    required this.availableCoins,
    required this.minimumUse,
    required this.seller,
    required this.carts,
  });

  bool get isSuccess => status.toLowerCase() == 'success';

  factory GetCartResponse.fromJson(Map<String, dynamic> j) => GetCartResponse(
    status: (j['status'] ?? '').toString(),
    availableCoins: int.tryParse(j['available_coins'].toString()) ?? 0,
    minimumUse: int.tryParse(j['minimum_use'].toString()) ?? 0,
    seller: j['seller'] == null || j['seller'] == false
        ? null
        : SellerInfo.fromJson(j['seller'] ?? {}),
    carts: (j['carts'] as List<dynamic>? ?? [])
        .map((e) => CartItem.fromJson(e))
        .toList(),
  );
}

/// ─────────────────────────────────────────
/// 🟦 SERVICE CLASS
/// ─────────────────────────────────────────

class GetCartsService {
  GetCartsService({TokenProvider? getToken})
    : _getToken = getToken ?? TokenStorage.getToken,
      _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;
  final TokenProvider _getToken;

  /// Fetch cart
  Future<GetCartResponse> getCarts() async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Not authenticated. Missing token.');
    }

    final uri = Uri.parse('$_base/get_carts.php');
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    final res = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final parsed = GetCartResponse.fromJson(json);

    if (!parsed.isSuccess) {
      throw Exception('Failed to load cart details.');
    }

    return parsed;
  }

  /// Fetch product colors
  Future<List<ProductColor>> getProductColors(String productId) async {
    final token = await _getToken();
    final uri = Uri.parse(
      '$_base/get_product_colors.php?product_id=$productId',
    );
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    final res = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('Failed to load colors');

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    print(json);
    if (json['status']?.toString().toLowerCase() != 'success') return [];

    final list = (json['colors'] as List<dynamic>? ?? [])
        .map((e) => ProductColor.fromJson(e))
        .toList();

    return list;
  }

  /// Fetch product variants
  Future<List<ProductVariant>> getProductVariants(String productId) async {
    final token = await _getToken();
    final uri = Uri.parse(
      '$_base/get_product_variants.php?product_id=$productId',
    );
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    final res = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('Failed to load variants');

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    print(json);
    if (json['status']?.toString().toLowerCase() != 'success') return [];

    final list = (json['variants'] as List<dynamic>? ?? [])
        .map((e) => ProductVariant.fromJson(e))
        .toList();

    return list;
  }

  /// DELETE CART ITEM
  Future<bool> deleteCartItem(String cartId) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Not authenticated. Missing token.');
    }

    final uri = Uri.parse('$_base/delete_cart.php');

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({'cart_id': int.tryParse(cartId) ?? cartId});

    final res = await http
        .delete(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final json = jsonDecode(res.body);
    final status = json['status']?.toString().toLowerCase() ?? '';

    if (status == 'success') {
      debugPrint('✅ Cart item deleted successfully (cart_id: $cartId)');
      return true;
    } else {
      debugPrint(
        '⚠️ Failed to delete cart item (cart_id: $cartId): ${json['message']}',
      );
      return false;
    }
  }
}
