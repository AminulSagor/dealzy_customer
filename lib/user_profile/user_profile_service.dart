import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:dealzy/storage/token_storage.dart';
import 'package:http_parser/http_parser.dart';

typedef TokenProvider = Future<String?> Function();

/// One item from GET /get_bookmarked_products.php
class BookmarkedProduct {
  final String productId;
  final String productName;
  final String imagePath;
  final double price;
  final double? offerPrice;

  const BookmarkedProduct({
    required this.productId,
    required this.productName,
    required this.imagePath,
    required this.price,
    this.offerPrice,
  });

  factory BookmarkedProduct.fromJson(Map<String, dynamic> j) {
    double? _tryDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return double.tryParse(s);
    }

    return BookmarkedProduct(
      productId: (j['product_id'] ?? '').toString(),
      productName: (j['product_name'] ?? '').toString(),
      imagePath: (j['image_path'] ?? '').toString(),
      price: _tryDouble(j['price']) ?? 0.0,
      offerPrice: _tryDouble(j['offer_price']),
    );
  }
}

/// Paged response for bookmarked products
class BookmarkedPage {
  final String status;
  final int currentPage;
  final int totalProducts;
  final int totalPages;
  final List<BookmarkedProduct> data;

  const BookmarkedPage({
    required this.status,
    required this.currentPage,
    required this.totalProducts,
    required this.totalPages,
    required this.data,
  });

  bool get isSuccess => status.toLowerCase() == 'success';

  factory BookmarkedPage.fromJson(Map<String, dynamic> j) {
    int _toInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    final items = (j['data'] as List? ?? [])
        .map((e) => BookmarkedProduct.fromJson(e as Map<String, dynamic>))
        .toList();

    return BookmarkedPage(
      status: (j['status'] ?? '').toString(),
      currentPage: _toInt(j['current_page']),
      totalProducts: _toInt(j['total_products']),
      totalPages: _toInt(j['total_pages']),
      data: items,
    );
  }
}

/// Profile payload from GET /get_user_profile.php
class UserProfileData {
  final String name;
  final String phone;
  final String postCode;
  final String adminDistrict;
  final String imagePath;
  final int coins;

  const UserProfileData({
    required this.name,
    required this.phone,
    required this.postCode,
    required this.adminDistrict,
    required this.imagePath,
    required this.coins,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> j) {
    final d = (j['data'] as Map<String, dynamic>? ?? const {});
    return UserProfileData(
      name: (d['name'] ?? '').toString(),
      phone: (d['phone'] ?? '').toString(),
      postCode: (d['post_code'] ?? '').toString(),
      adminDistrict: (d['admin_dis'] ?? '').toString(),
      imagePath: (d['image_path'] ?? '').toString(),
      coins: int.tryParse(d['coins']) ?? 0,
    );
  }
}

class UserProfileService {
  UserProfileService({TokenProvider? getToken})
    : _getToken = getToken ?? TokenStorage.getToken,
      _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;
  final TokenProvider _getToken;

  /// GET /get_user_profile.php
  Future<UserProfileData> fetchUserProfile() async {
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

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final data = UserProfileData.fromJson(json);

    if ((json['status'] ?? '').toString().toLowerCase() != 'success') {
      throw Exception('Failed to fetch profile');
    }
    return data;
  }

  /// GET /get_bookmarked_products.php?page=&limit=
  Future<BookmarkedPage> fetchBookmarkedProducts({
    int page = 1,
    int limit = 10,
  }) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Not authenticated. Missing token.');
    }

    final uri = Uri.parse(
      '$_base/get_bookmarked_products.php?page=$page&limit=$limit',
    );
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

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final pageObj = BookmarkedPage.fromJson(json);

    if (!pageObj.isSuccess) {
      throw Exception('Failed to fetch bookmarks');
    }
    return pageObj;
  }

  Future<void> removeBookmark(String productId) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Not authenticated. Missing token.');
    }

    final uri = Uri.parse('$_base/remove_bookmark.php');
    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = jsonEncode({
      'product_id': int.tryParse(productId) ?? productId,
    });

    final res = await http
        .delete(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final status = (json['status'] ?? '').toString().toLowerCase();
    final message = (json['message'] ?? '').toString();

    if (status != 'success') {
      throw Exception(message.isEmpty ? 'Failed to remove bookmark' : message);
    }
  }

  /// POST /upload_profile.php
  /// Returns the absolute URL of the uploaded profile image.
  Future<String> uploadProfileImage(File file) async {
    if (_base.isEmpty)
      throw StateError('API_BASE_URL is empty. Check your .env.');

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Not authenticated. Missing token.');
    }

    final uri = Uri.parse('$_base/upload_profile.php');
    final req = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      })
      ..files.add(
        await http.MultipartFile.fromPath(
          'profile_image',
          file.path,
          // best effort: infer content type by extension
          contentType: () {
            final p = file.path.toLowerCase();
            if (p.endsWith('.png')) return MediaType('image', 'png');
            if (p.endsWith('.jpg') || p.endsWith('.jpeg'))
              return MediaType('image', 'jpeg');
            return MediaType('application', 'octet-stream');
          }(),
        ),
      );

    final streamed = await req.send().timeout(const Duration(seconds: 30));
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final status = (json['status'] ?? '').toString().toLowerCase();
    if (status != 'success') {
      throw Exception((json['message'] ?? 'Upload failed').toString());
    }

    final url = (json['profile_image'] ?? '').toString().trim();
    if (url.isEmpty)
      throw Exception('Upload succeeded but no image URL returned.');
    return url;
  }
}
