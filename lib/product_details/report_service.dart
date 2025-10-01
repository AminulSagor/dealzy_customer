import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReportService {
  ReportService()
      : _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;

  Future<Map<String, dynamic>> reportProduct({
    required String productId,
    required String reportText,
    required String token, // ✅ pass token here
  }) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }

    final uri = Uri.parse('$_base/report_product.php');

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // ✅ include token in header
      },
      body: jsonEncode({
        'product_id': productId,
        'report': reportText,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return json; // contains status + message
  }
}
