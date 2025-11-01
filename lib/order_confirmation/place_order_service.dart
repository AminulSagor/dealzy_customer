import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:dealzy/storage/token_storage.dart';

typedef TokenProvider = Future<String?> Function();

/// ─────────────────────────────────────────
/// 🟩 MODELS
/// ─────────────────────────────────────────

class OrderItem {
  final String cartId;
  final int quantity;
  final double rate;
  final String? colorId;
  final String? variantId;

  const OrderItem({
    required this.cartId,
    required this.quantity,
    required this.rate,
    this.colorId,
    this.variantId,
  });

  Map<String, dynamic> toJson() => {
    'cart_id': cartId,
    'quantity': quantity,
    'rate': rate,
    if (colorId != null && colorId!.isNotEmpty) 'color_id': colorId,
    if (variantId != null && variantId!.isNotEmpty) 'variant_id': variantId,
  };
}

class PlaceOrderResponse {
  final String status;
  final String message;

  const PlaceOrderResponse({required this.status, required this.message});

  bool get isSuccess => status.toLowerCase() == 'success';

  factory PlaceOrderResponse.fromJson(Map<String, dynamic> j) =>
      PlaceOrderResponse(
        status: (j['status'] ?? '').toString(),
        message: (j['message'] ?? '').toString(),
      );
}

/// ─────────────────────────────────────────
/// 🟦 SERVICE CLASS
/// ─────────────────────────────────────────

class PlaceOrderService {
  PlaceOrderService({TokenProvider? getToken})
    : _getToken = getToken ?? TokenStorage.getToken,
      _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;
  final TokenProvider _getToken;

  /// ✅ Place an order with discount, notes, and items
  Future<PlaceOrderResponse> placeOrder({
    double? discount,
    String? notes,
    required List<OrderItem> items,
  }) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env file.');
    }

    if (items.isEmpty) {
      throw ArgumentError('Items list cannot be empty.');
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Not authenticated. Missing token.');
    }

    final uri = Uri.parse('$_base/place_order.php');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    var body = {
      if (discount != null && discount > 0) 'discount': discount,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      'items': items.map((e) => e.toJson()).toList(),
    };

    final res = await http
        .post(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final parsed = PlaceOrderResponse.fromJson(json);

    if (!parsed.isSuccess) {
      throw Exception(
        parsed.message.isEmpty ? 'Order creation failed.' : parsed.message,
      );
    }

    return parsed;
  }

  Future<String?> createPaymentIntent(String amount, String currency) async {
    // Your backend URL
    try {
      if (_base.isEmpty) {
        throw StateError('API_BASE_URL is empty. Check your .env file.');
      }

      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw StateError('Not authenticated. Missing token.');
      }

      final uri = Uri.parse('$_base/get_payment_intent.php');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      var body = {'amount': amount, 'currency': currency};

      final res = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final jsonResponse = jsonDecode(res.body);
        return jsonResponse['client_secret'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
