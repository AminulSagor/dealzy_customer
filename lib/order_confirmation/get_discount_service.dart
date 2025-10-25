import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:dealzy/storage/token_storage.dart';

typedef TokenProvider = Future<String?> Function();

/// ─────────────────────────────────────────
/// 🟩 MODEL
/// ─────────────────────────────────────────
class DiscountResponse {
  final String status;
  final String message;
  final double discount;

  const DiscountResponse({
    required this.status,
    required this.message,
    required this.discount,
  });

  bool get isSuccess => status.toLowerCase() == 'success';

  factory DiscountResponse.fromJson(Map<String, dynamic> j) => DiscountResponse(
    status: (j['status'] ?? '').toString(),
    message: (j['message'] ?? '').toString(),
    discount: double.tryParse(j['discount']?.toString() ?? '0') ?? 0.0,
  );
}

/// ─────────────────────────────────────────
/// 🟦 SERVICE CLASS
/// ─────────────────────────────────────────
class GetDiscountService {
  GetDiscountService({TokenProvider? getToken})
    : _getToken = getToken ?? TokenStorage.getToken,
      _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;
  final TokenProvider _getToken;

  /// ✅ Fetch discount estimation based on subtotal, coupon & coins
  Future<DiscountResponse> estimateDiscount({
    required double subTotal,
    String? coupon,
    int? coins,
  }) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env file.');
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Not authenticated. Missing token.');
    }

    final uri = Uri.parse('$_base/estimate_discount.php');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final body = {
      'sub_total': subTotal,
      if (coupon != null && coupon.isNotEmpty) 'coupon': coupon,
      if (coins != null && coins > 0) 'coins': coins,
    };

    final res = await http
        .post(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final parsed = DiscountResponse.fromJson(json);

    if (!parsed.isSuccess) {
      throw Exception(
        parsed.message.isEmpty ? 'Discount estimation failed.' : parsed.message,
      );
    }

    return parsed;
  }
}
