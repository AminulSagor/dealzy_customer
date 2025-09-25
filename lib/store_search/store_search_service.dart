import 'package:dealzy/store_search/store_item_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage/token_storage.dart';


class StoreSearchPage {
  final int currentPage;
  final int totalStores;
  final int totalPages;
  final List<StoreItem> data;

  StoreSearchPage({
    required this.currentPage,
    required this.totalStores,
    required this.totalPages,
    required this.data,
  });

  factory StoreSearchPage.fromJson(Map<String, dynamic> j) {
    int _toInt(dynamic v) => int.tryParse((v ?? '').toString()) ?? 0;
    final list = (j['data'] as List? ?? [])
        .map((e) => StoreItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return StoreSearchPage(
      currentPage:  _toInt(j['current_page']),
      totalStores:  _toInt(j['total_stores']),
      totalPages:   _toInt(j['total_pages']),
      data: list,
    );
  }
}

class StoreSearchService {
  StoreSearchService()
      : _base = (dotenv.env['API_BASE_URL'] ?? '')
      .replaceAll(RegExp(r'/+$'), '');

  final String _base;
  final Dio _dio = Dio();

  Future<StoreSearchPage> searchByPostcode({
    required String postcode,
    int page = 1,
    int limit = 10,
  }) async {
    final token = await TokenStorage.getToken();
    if (_base.isEmpty) throw StateError('API_BASE_URL is empty');
    if (token == null || token.isEmpty) throw StateError('Missing token');
    if (postcode.trim().isEmpty) throw ArgumentError('postcode is required');

    final uri = '$_base/search_stores.php';
    final res = await _dio.get(
      uri,
      queryParameters: {
        'post_code': postcode,
        'page': page,
        'limit': limit,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.statusMessage}');
    }
    final body = res.data as Map<String, dynamic>;
    if ((body['status'] ?? '').toString().toLowerCase() != 'success') {
      throw Exception('Failed to load stores');
    }
    return StoreSearchPage.fromJson(body);
  }

  Future<StoreSearchPage> searchByLatLng({
    required double latitude,
    required double longitude,
    int page = 1,
    int limit = 10,
  }) async {
    final token = await TokenStorage.getToken();
    if (_base.isEmpty) throw StateError('API_BASE_URL is empty');
    if (token == null || token.isEmpty) throw StateError('Missing token');

    final uri = '$_base/search_stores.php';
    final res = await _dio.get(
      uri,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'page': page,
        'limit': limit,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.statusMessage}');
    }
    final body = res.data as Map<String, dynamic>;
    if ((body['status'] ?? '').toString().toLowerCase() != 'success') {
      throw Exception('Failed to load stores');
    }
    return StoreSearchPage.fromJson(body);
  }
}
