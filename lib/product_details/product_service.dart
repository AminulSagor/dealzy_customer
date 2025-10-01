import 'dart:convert';
import 'package:dealzy/product_details/product_details_models.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ProductService {
  ProductService()
      : _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;

  Future<Map<String, dynamic>> fetchDetailsRaw(String productId) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }
    final uri = Uri.parse('$_base/product_details.php')
        .replace(queryParameters: {'product_id': productId});

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if ((json['status'] as String?)?.toLowerCase() != 'success') {
      throw Exception('API status != success');
    }
    return Map<String, dynamic>.from(json['data'] as Map);
  }

  Future<ProductDetailsData> fetchDetails(String productId) async {
    final data = await fetchDetailsRaw(productId);
    return ProductDetailsData.fromApi(data);
  }
}
