// lib/service/verify_otp_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VerifyOtpService {
  VerifyOtpService({http.Client? client})
      : _client = client ?? http.Client(),
        _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  final http.Client _client;
  final String _baseUrl;

  static const Duration _timeout = Duration(seconds: 20);

  /// Verify OTP for given email
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('API_BASE_URL is not set in .env');
    }

    final uri = Uri.parse('$_baseUrl/verify_otp.php');

    final response = await _client
        .post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'email': email,
        'otp': otp,
      }),
    )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to verify OTP (${response.statusCode}): ${response.body}');
    }

    try {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return {
        'status': (decoded['status'] ?? '').toString(),
        'message': (decoded['message'] ?? '').toString(),
      };
    } catch (_) {
      throw Exception('Unexpected response format: ${response.body}');
    }
  }
}
