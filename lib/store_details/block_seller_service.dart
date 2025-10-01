import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BlockSellerService {
  BlockSellerService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  String get _base =>
      (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  Future<Map<String, dynamic>> blockSeller({
    required String sellerId,
    required String token,
  }) async {
    if (_base.isEmpty) {
      throw Exception('API_BASE_URL is not set in .env');
    }
    final uri = Uri.parse('$_base/block_seller.php');

    final res = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'seller_id': sellerId}),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final Map<String, dynamic> body = jsonDecode(res.body);
    return body;
  }

  void dispose() {
    _client.close();
  }
}
