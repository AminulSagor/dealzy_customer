import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginService {
  late final Dio _dio;

  LoginService() {
    final raw = dotenv.maybeGet('API_BASE_URL') ?? 'https://dealzyloop.com/api';
    final base = raw.trim().replaceAll(RegExp(r'/*$'), ''); // strip trailing slash

    _dio = Dio(
      BaseOptions(
        baseUrl: base, // e.g. https://dealzyloop.com/api
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );


  }

  /// POST /user_login.php
  /// Returns: (success, status, message, user)
  Future<({
  bool success,
  String status,
  String message,
  Map<String, dynamic>? user,
  })> login({
    required String phone,
    required String password,
  }) async {
    const path = '/user_login.php';

    final body = {
      'phone': phone,
      'password': password,
    };

    final res = await _dio.post(path, data: body);

    final data = res.data is String ? jsonDecode(res.data as String) : res.data;
    final map = (data as Map<String, dynamic>);

    final status = (map['status'] ?? '').toString();
    final message = (map['message'] ?? '').toString();
    final user = map['user'] is Map<String, dynamic> ? map['user'] as Map<String, dynamic> : null;

    return (success: status.toLowerCase() == 'success', status: status, message: message, user: user);
  }
}
