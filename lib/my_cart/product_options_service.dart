import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:dealzy/storage/token_storage.dart';
import 'get_carts_service.dart'; // to reuse ProductColor / ProductVariant + TokenProvider

/// This service is responsible ONLY for product-specific option metadata:
/// - available colors
/// - available variants
///
/// You call this when user opens the bottom sheet for a cart item
/// or when you want to prefill options.

class ProductOptionsService {
  ProductOptionsService({TokenProvider? getToken})
    : _getToken = getToken ?? TokenStorage.getToken,
      _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;
  final TokenProvider _getToken;

  /// GET /get_product_colors.php?product_id={id}
  Future<List<ProductColor>> getProductColors(String productId) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Not authenticated. Missing token.');
    }

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

    if (res.statusCode != 200) {
      throw Exception('Failed to load colors');
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    if (jsonMap['status']?.toString().toLowerCase() != 'success') {
      return [];
    }

    final list = (jsonMap['colors'] as List<dynamic>? ?? [])
        .map((e) => ProductColor.fromJson(e as Map<String, dynamic>))
        .toList();

    return list;
  }

  /// GET /get_product_variants.php?product_id={id}
  Future<List<ProductVariant>> getProductVariants(String productId) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Not authenticated. Missing token.');
    }

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

    if (res.statusCode != 200) {
      throw Exception('Failed to load variants');
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    if (jsonMap['status']?.toString().toLowerCase() != 'success') {
      return [];
    }

    final list = (jsonMap['variants'] as List<dynamic>? ?? [])
        .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
        .toList();

    return list;
  }
}
