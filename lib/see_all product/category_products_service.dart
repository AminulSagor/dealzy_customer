// lib/services/category_products_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// One product row from GET /get_products_by_category.php
class CategoryProduct {
  final String id;
  final String title;
  final String image;
  final double price;
  final double? offerPrice;

  const CategoryProduct({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    this.offerPrice,
  });

  factory CategoryProduct.fromJson(Map<String, dynamic> j) {
    double? _tryDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return double.tryParse(s);
    }

    return CategoryProduct(
      id: (j['product_id'] ?? '').toString(),
      title: (j['product_name'] ?? '').toString(),
      image: (j['image_path'] ?? '').toString(),
      price: _tryDouble(j['price']) ?? 0.0,
      offerPrice: _tryDouble(j['offer_price']),
    );
  }
}

/// Paged response for category products
class CategoryProductsPage {
  final String status;
  final int currentPage;
  final int totalProducts;
  final int totalPages;
  final List<CategoryProduct> data;

  const CategoryProductsPage({
    required this.status,
    required this.currentPage,
    required this.totalProducts,
    required this.totalPages,
    required this.data,
  });

  bool get isSuccess => status.toLowerCase() == 'success';

  factory CategoryProductsPage.fromJson(Map<String, dynamic> j) {
    int _toInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    final items = (j['data'] as List? ?? [])
        .map((e) => CategoryProduct.fromJson(e as Map<String, dynamic>))
        .toList();

    return CategoryProductsPage(
      status: (j['status'] ?? '').toString(),
      currentPage: _toInt(j['current_page']),
      totalProducts: _toInt(j['total_products']),
      totalPages: _toInt(j['total_pages']),
      data: items,
    );
  }
}

class CategoryProductsService {
  CategoryProductsService()
      : _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;

  /// GET /get_products_by_category.php?category_id=..&page=..&limit=..
  Future<CategoryProductsPage> fetchProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 10,
  }) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }
    if (categoryId.trim().isEmpty) {
      throw ArgumentError('categoryId is required');
    }

    final uri = Uri.parse(
      '$_base/get_products_by_category.php?category_id=$categoryId&page=$page&limit=$limit',
    );

    final headers = <String, String>{
      'Accept': 'application/json',
    }; // NO AUTH

    if (kDebugMode) {
      debugPrint('⇢ GET $uri');
    }

    final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));

    if (kDebugMode) {
      debugPrint('⇠ ${res.statusCode} ${res.reasonPhrase}');
      try {
        debugPrint(const JsonEncoder.withIndent('  ').convert(jsonDecode(res.body)));
      } catch (_) {
        debugPrint(res.body);
      }
    }

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final pageObj = CategoryProductsPage.fromJson(json);

    if (!pageObj.isSuccess) {
      throw Exception('Failed to fetch category products');
    }
    return pageObj;
  }


  Future<CategoryProductsPage> searchProducts({
    required String keyword,
    int page = 1,
    int limit = 10,
  }) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }
    final q = keyword.trim();
    if (q.isEmpty) {
      // return empty page for UX simplicity
      return const CategoryProductsPage(
        status: 'success',
        currentPage: 1,
        totalProducts: 0,
        totalPages: 1,
        data: <CategoryProduct>[],
      );
    }

    final uri = Uri.parse(
      '$_base/search_products.php?keyword=${Uri.encodeQueryComponent(q)}&page=$page&limit=$limit',
    );

    final headers = <String, String>{'Accept': 'application/json'};

    if (kDebugMode) debugPrint('⇢ GET $uri');
    final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
    if (kDebugMode) {
      debugPrint('⇠ ${res.statusCode} ${res.reasonPhrase}');
      try {
        debugPrint(const JsonEncoder.withIndent('  ').convert(jsonDecode(res.body)));
      } catch (_) {
        debugPrint(res.body);
      }
    }

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final pageObj = CategoryProductsPage.fromJson(json);
    if (!pageObj.isSuccess) {
      throw Exception('Failed to search products');
    }
    return pageObj;
  }

  void dispose() {
    // keep for parity / future cleanup needs
  }
}
