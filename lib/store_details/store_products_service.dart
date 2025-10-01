import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../combine_model/product_item_model.dart';


class PaginatedProducts {
  final List<ProductItem> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  const PaginatedProducts({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });
}

class StoreProductsService {
  StoreProductsService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  String get _base =>
      (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/*$'), '');

  Future<PaginatedProducts> fetchByStore({
    required String storeId,
    int page = 1,
    int limit = 20,
  }) async {
    if (_base.isEmpty) {
      throw Exception('API_BASE_URL is not set in .env');
    }

    final uri = Uri.parse(
        '$_base/get_products_by_store.php?store_id=$storeId&page=$page&limit=$limit');




    final res = await _client.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final Map<String, dynamic> body = jsonDecode(res.body);
    if (body['status'] != 'success') {
      throw Exception('API error: ${body['status'] ?? 'unknown'}');
    }

    final List data = (body['data'] as List?) ?? const [];
    final items = data.map((e) => ProductItem.fromJson(e)).toList();

    return PaginatedProducts(
      items: items,
      currentPage: (body['current_page'] as num?)?.toInt() ?? page,
      totalPages: (body['total_pages'] as num?)?.toInt() ?? 1,
      totalItems: (body['total_products'] as num?)?.toInt() ?? items.length,
    );
  }

  void dispose() {
    _client.close();
  }

}
