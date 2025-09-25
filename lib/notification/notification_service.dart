// lib/services/notification_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NotificationDto {
  final String id;
  final String title;
  final String text;
  final String createdAt;

  const NotificationDto({
    required this.id,
    required this.title,
    required this.text,
    required this.createdAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> j) => NotificationDto(
    id: (j['id'] ?? '').toString(),
    title: (j['title'] ?? '').toString(),
    text: (j['text'] ?? '').toString(),
    createdAt: (j['created_at'] ?? '').toString(),
  );
}

class NotificationPage {
  final String status;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<NotificationDto> data;

  const NotificationPage({
    required this.status,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  bool get isSuccess => status.toLowerCase() == 'success';

  factory NotificationPage.fromJson(Map<String, dynamic> j) {
    int _toInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    final List<NotificationDto> items =
    (j['data'] as List? ?? [])
        .map((e) => NotificationDto.fromJson(e as Map<String, dynamic>))
        .toList();

    return NotificationPage(
      status: (j['status'] ?? '').toString(),
      page: _toInt(j['page']),
      limit: _toInt(j['limit']),
      total: _toInt(j['total']),
      totalPages: _toInt(j['total_pages']),
      data: items,
    );
  }
}

class NotificationService {
  NotificationService()
      : _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;

  /// GET /get_all_notification.php?page=&limit=
  /// No auth required.
  Future<NotificationPage> fetchAll({
    int page = 1,
    int limit = 10,
  }) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env.');
    }

    final uri = Uri.parse('$_base/get_all_notification.php?page=$page&limit=$limit');
    final headers = <String, String>{'Accept': 'application/json'};

    if (kDebugMode) {
      debugPrint('⇢ GET $uri');
    }

    final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));

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

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final pageObj = NotificationPage.fromJson(json);

    if (!pageObj.isSuccess) {
      throw Exception('Failed to fetch notifications');
    }
    return pageObj;
  }
}
