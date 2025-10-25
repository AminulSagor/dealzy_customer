import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:dealzy/storage/token_storage.dart';

typedef TokenProvider = Future<String?> Function();

class AddToCartResponse {
  final String status;
  final String message;
  const AddToCartResponse({required this.status, required this.message});

  bool get isSuccess => status.toLowerCase() == 'success';

  factory AddToCartResponse.fromJson(Map<String, dynamic> j) =>
      AddToCartResponse(
        status: (j['status'] ?? '').toString(),
        message: (j['message'] ?? '').toString(),
      );
}

class AddToCartService {
  AddToCartService({TokenProvider? getToken})
    : _getToken =
          getToken ?? TokenStorage.getToken, // <- default from your storage
      _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;
  final TokenProvider _getToken;

  Future<AddToCartResponse> addToCart(String productId) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Not authenticated. Missing token.');
    }

    final uri = Uri.parse('$_base/add_to_cart.php');
    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = jsonEncode({
      'product_id': int.tryParse(productId) ?? productId,
    });

    final res = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final parsed = AddToCartResponse.fromJson(json);

    if (!parsed.isSuccess) {
      throw Exception(
        parsed.message.isEmpty ? 'Add to cart failed' : parsed.message,
      );
    }
    return parsed;
  }
}
