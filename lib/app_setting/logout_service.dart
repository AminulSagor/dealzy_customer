import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';

typedef TokenProvider = Future<String?> Function();

class LogoutResponse {
  final String status;
  final String message;
  const LogoutResponse({required this.status, required this.message});
  bool get isSuccess => status.toLowerCase() == 'success';

  factory LogoutResponse.fromJson(Map<String, dynamic> j) => LogoutResponse(
    status: (j['status'] ?? '').toString(),
    message: (j['message'] ?? '').toString(),
  );
}

class LogoutService {
  LogoutService({TokenProvider? getToken})
      : _getToken = getToken ?? TokenStorage.getToken,
        _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;
  final TokenProvider _getToken;

  /// DELETE /logout.php  (Bearer token required)
  Future<LogoutResponse> logout() async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      // Treat as a state error so the caller can decide UX (e.g., clear local state anyway)
      throw StateError('Not authenticated. Missing token.');
    }

    final uri = Uri.parse('$_base/logout.php');
    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    if (kDebugMode) {
      debugPrint('⇢ DELETE $uri');
      debugPrint('Headers: Authorization: Bearer ***');
    }

    final res = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 20));

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

    final Map<String, dynamic> json = jsonDecode(res.body) as Map<String, dynamic>;
    final parsed = LogoutResponse.fromJson(json);
    if (!parsed.isSuccess) {
      throw Exception(parsed.message.isEmpty ? 'Logout failed' : parsed.message);
    }
    return parsed;
  }
}
