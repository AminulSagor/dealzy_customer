import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignupService {
  late final Dio _dio;

  SignupService() {
    // Read from .env or fallback
    final raw = dotenv.maybeGet('API_BASE_URL') ?? 'https://dealzyloop.com/api';
    final base = raw.trim().replaceAll(RegExp(r'/*$'), ''); // strip trailing slash

    _dio = Dio(
      BaseOptions(
        baseUrl: base, // <- loaded directly here
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Optional: enable logging during development
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  /// POST /user_reg.php
  /// Returns a simple record: (success, status, message)
  Future<({bool success, String status, String message})> signUp({
    required String name,
    required String phone,
    required String email,        // 👈 added
    required String password,
    required double latitude,
    required double longitude,
    String? postCode,
    String? adminDistrict,
  }) async {
    const path = '/user_reg.php';

    final body = <String, dynamic>{
      'name': name,
      'phone': phone,
      'email': email,             // 👈 added
      'password': password,
      'post_code': postCode,
      'latitude': latitude,
      'longitude': longitude,
      'admin_district': adminDistrict,
    }..removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));

    final res = await _dio.post(path, data: body);

    // Some servers return a string; normalize to Map
    final data = res.data is String ? jsonDecode(res.data as String) : res.data;
    final map = (data as Map<String, dynamic>);

    final status = (map['status'] ?? '').toString();
    final message = (map['message'] ?? '').toString();
    final success = status.toLowerCase() == 'success';

    return (success: success, status: status, message: message);
  }
}
