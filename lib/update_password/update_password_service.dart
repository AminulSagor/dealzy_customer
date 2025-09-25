import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UpdatePasswordService {
  UpdatePasswordService({http.Client? client})
      : _client = client ?? http.Client(),
        _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  final http.Client _client;
  final String _baseUrl;
  static const _timeout = Duration(seconds: 20);

  /// POST /reset_password.php
  /// Headers: { otp: <OTP> }
  /// Body   : { "email": "...", "password": "..." }
  Future<Map<String, dynamic>> updatePassword({
    required String email,
    required String password,
    required String otp, // sent in HEADER (required)
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('API_BASE_URL is not set in .env');
    }

    final uri = Uri.parse('$_baseUrl/reset_password.php');

    final res = await _client
        .post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'otp': otp, // <-- required by backend
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    )
        .timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception('Failed to reset password (${res.statusCode}): ${res.body}');
    }

    final decoded = json.decode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected response: ${res.body}');
    }
    return {
      'status': (decoded['status'] ?? '').toString(),
      'message': (decoded['message'] ?? '').toString(),
    };
  }
}
