
import 'dart:convert';
import 'package:dealzy/home/slider_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';
import 'category_model.dart';
import '../home/home_products_model.dart'; // ← add this import (adjust path if needed)

class HomeService {
  HomeService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        baseUrl = (baseUrl ??
            dotenv.env['API_BASE_URL'] ?? '')
            .replaceAll(RegExp(r'/+$'), '');

  final http.Client _client;
  final String baseUrl;

  Future<List<CategoryDto>> getAllCategories() async {
    final uri = Uri.parse('$baseUrl/get_all_category.php');

    final res = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Category fetch failed [${res.statusCode}]');
    }

    final Map<String, dynamic> data = json.decode(res.body);
    final parsed = CategoryApiResponse.fromJson(data);

    if (parsed.status != 'success') {
      throw Exception('Category API status: ${parsed.status}');
    }

    return parsed.categories;
  }

  Future<List<SliderDto>> getAllSliders() async {
    final uri = Uri.parse('$baseUrl/get_all_sliders.php');

    final res = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Sliders fetch failed [${res.statusCode}]');
    }

    final data = json.decode(res.body) as Map<String, dynamic>;
    final parsed = SliderApiResponse.fromJson(data);

    if (parsed.status != 'success') {
      throw Exception('Sliders API status: ${parsed.status}');
    }

    return parsed.sliders;
  }

  // *************** NEW: Home products ***************
  /// offer ∈ {'regular','expiring_soon','clearance'}
  Future<HomeProductsResponse> getHomeProducts({
    required String offer,
    int page = 1,
    int limit = 10,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/home_page_products.php?offer=$offer&page=$page&limit=$limit',
    );

    // look up token inside the function
    final token = await TokenStorage.getToken();

    // build headers dynamically
    final headers = <String, String>{
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final res = await _client
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Products fetch failed [$offer][${res.statusCode}]');
    }

    final data = json.decode(res.body) as Map<String, dynamic>;
    final parsed = HomeProductsResponse.fromJson(data);

    if (parsed.status != 'success') {
      throw Exception('Products API status for $offer: ${parsed.status}');
    }

    return parsed;
  }

  // ***************************************************

  void dispose() {
    _client.close();
  }
}
