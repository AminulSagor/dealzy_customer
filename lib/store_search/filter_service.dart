import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 👈 import dotenv
import '../storage/token_storage.dart';

class SuggestionItem {
  final String? postCode;
  final String adminDis;

  SuggestionItem({
    this.postCode,
    required this.adminDis,
  });

  factory SuggestionItem.fromJson(Map<String, dynamic> json) {
    return SuggestionItem(
      postCode: json['post_code']?.toString(),
      adminDis: json['admin_dis']?.toString() ?? '',
    );
  }
}

class FilterService {
  late final Dio _dio;

  FilterService() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      throw Exception("Missing API_BASE_URL in .env");
    }
    _dio = Dio(BaseOptions(baseUrl: baseUrl));
  }

  Future<List<SuggestionItem>> fetchFilterOptions() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Missing token");
    }

    final res = await _dio.get(
      "/get_filter_options.php",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    if (res.statusCode == 200 &&
        res.data is Map &&
        res.data["status"] == "success") {
      final List data = res.data["data"] ?? [];
      return data
          .map((e) => SuggestionItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("Failed to load filter options");
    }
  }
}
