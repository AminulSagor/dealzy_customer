import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';

class ProfileData {
  final String name;
  final String phone;
  final String postCode;
  final String adminDistrict;
  final String imagePath;

  const ProfileData({
    required this.name,
    required this.phone,
    required this.postCode,
    required this.adminDistrict,
    required this.imagePath,
  });

  factory ProfileData.fromJson(Map<String, dynamic> j) {
    final d = (j['data'] as Map<String, dynamic>? ?? const {});
    return ProfileData(
      name: (d['name'] ?? '').toString(),
      phone: (d['phone'] ?? '').toString(),
      postCode: (d['post_code'] ?? '').toString(),
      adminDistrict: (d['admin_dis'] ?? '').toString(),
      imagePath: (d['image_path'] ?? '').toString(),
    );
  }
}

typedef TokenProvider = Future<String?> Function();

class ProfileService {
  ProfileService({TokenProvider? getToken})
    : _getToken = getToken ?? TokenStorage.getToken,
      _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;
  final TokenProvider _getToken;

  /// GET /get_user_profile.php  (Bearer token required)
  Future<ProfileData> getProfile() async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Not authenticated. Missing token.');
    }

    final uri = Uri.parse('$_base/get_user_profile.php');
    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    final res = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final Map<String, dynamic> json =
        jsonDecode(res.body) as Map<String, dynamic>;
    final status = (json['status'] ?? '').toString().toLowerCase();
    if (status != 'success') {
      throw Exception('Profile fetch failed');
    }

    return ProfileData.fromJson(json);
  }
}
