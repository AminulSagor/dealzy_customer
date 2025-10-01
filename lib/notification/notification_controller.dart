
import 'package:get/get.dart';

import 'notification_service.dart';

class NotificationItem {
  final String title;
  final String body;
  final String time;
  NotificationItem({required this.title, required this.body, required this.time});
}

class NotificationController extends GetxController {
  NotificationController({NotificationService? service})
      : _service = service ?? NotificationService();

  final NotificationService _service;

  // UI list
  final items = <NotificationItem>[].obs;

  // State
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final error = RxnString();

  // Pagination
  final _page = 1.obs;
  final _limit = 10.obs;
  final _totalPages = 1.obs;

  int get currentPage => _page.value;
  int get totalPages => _totalPages.value;

  @override
  void onInit() {
    super.onInit();
    fetchFirstPage();
  }

  Future<void> fetchFirstPage({int limit = 10}) async {
    isLoading.value = true;
    error.value = null;
    items.clear();
    _page.value = 1;
    _limit.value = limit;

    try {
      final res = await _service.fetchAll(page: 1, limit: limit);
      _totalPages.value = res.totalPages;

      final mapped = res.data
          .map((d) => NotificationItem(
        title: d.title,
        body: d.text,
        time: d.createdAt, // keep as-is; format in the view if needed
      ))
          .toList();

      items.assignAll(mapped);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value) return;
    if (_page.value >= _totalPages.value) return;

    isLoadingMore.value = true;
    try {
      final next = _page.value + 1;
      final res = await _service.fetchAll(page: next, limit: _limit.value);
      _page.value = res.page;
      _totalPages.value = res.totalPages;

      final mapped = res.data
          .map((d) => NotificationItem(
        title: d.title,
        body: d.text,
        time: d.createdAt,
      ))
          .toList();

      items.addAll(mapped);
    } catch (_) {
      // Optional: surface a toast/snackbar if needed
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Optional: expose a retry for the view
  Future<void> retry() => fetchFirstPage(limit: _limit.value);
}
