import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignupService {
  late final Dio _dio;

  SignupService() {
    // Read from .env or fallback
    final raw = dotenv.maybeGet('API_BASE_URL') ?? 'https://dealzyloop.com/api';
    final base = raw.trim().replaceAll(RegExp(r'/*$'), ''); // strip trailing slash(es)

    _dio = Dio(
      BaseOptions(
        baseUrl: base,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// POST /user_reg.php
  /// Returns a simple record: (success, status, message)
  Future<({bool success, String status, String message})> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
    double? latitude,          // <-- now nullable
    double? longitude,         // <-- now nullable
    String? postCode,
    String? adminDistrict,
    // If later you want district/city/street, add them here as nullable too.
  }) async {
    const path = '/user_reg.php';

    final body = <String, dynamic>{
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      if (postCode != null && postCode.trim().isNotEmpty) 'post_code': postCode,
      if (adminDistrict != null && adminDistrict.trim().isNotEmpty)
        'admin_district': adminDistrict,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

    final res = await _dio.post(path, data: body);

    // Normalize response to Map
    final data = res.data is String ? jsonDecode(res.data as String) : res.data;
    final map = (data as Map<String, dynamic>);

    final status = (map['status'] ?? '').toString();
    final message = (map['message'] ?? '').toString();
    final success = status.toLowerCase() == 'success';

    return (success: success, status: status, message: message);
  }
}