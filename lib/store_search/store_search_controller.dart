import 'dart:async';
import 'package:dealzy/store_search/store_item_model.dart';
import 'package:dealzy/store_search/store_search_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import 'filter_service.dart';


class StoreSearchController extends GetxController {
  final queryCtrl = TextEditingController();

  // Suggestions
  final suggestions = <SuggestionItem>[].obs;
  final _allSuggestions = <SuggestionItem>[];

  // Store results
  final stores = <StoreItem>[].obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final pageSize = 10.obs;

  // Screen state
  final loading = false.obs;
  final error = RxnString();
  final showingStores = false
      .obs; // false = show suggestions list, true = show stores list

  // Services
  final _filterService = FilterService();
  final _storeService = StoreSearchService();

  Timer? _debouncer;

  @override
  void onInit() {
    super.onInit();
    fetchSuggestions();
    queryCtrl.addListener(_onQueryChanged);
  }

  @override
  void onClose() {
    queryCtrl.dispose();
    _debouncer?.cancel();
    super.onClose();
  }

  // ---------------- Suggestions ----------------
  Future<void> fetchSuggestions() async {
    try {
      loading.value = true;
      error.value = null;

      final result = await _filterService.fetchFilterOptions(); // List<SuggestionItem>
      _allSuggestions
        ..clear()
        ..addAll(result);
      suggestions.assignAll(result);
      showingStores.value = false; // ensure suggestions view
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  void _onQueryChanged() {
    _debouncer?.cancel();
    _debouncer = Timer(const Duration(milliseconds: 300), _applySuggestionFilter);
  }

  void _applySuggestionFilter() {
    // Only filter suggestions if we're on suggestions view
    if (showingStores.value) return;

    final q = queryCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      suggestions.assignAll(_allSuggestions);
      return;
    }
    suggestions.assignAll(
      _allSuggestions.where(
            (s) =>
        s.adminDis.toLowerCase().contains(q) ||
            (s.postCode?.toLowerCase().contains(q) ?? false),
      ),
    );
  }

  // ---------------- Stores search ----------------
  /// Call when a suggestion is selected; will fetch stores by `post_code`
  Future<void> selectSuggestionAndSearch(SuggestionItem s) async {
    final pc = (s.postCode ?? '').trim();
    if (pc.isEmpty) {
      Get.snackbar('Suggestion', 'No post code found for "${s.adminDis}"');
      return;
    }

    await _searchStoresByPostcode(postcode: pc, reset: true);
  }

  Future<void> _searchStoresByPostcode({
    required String postcode,
    bool reset = false,
  }) async {
    try {
      loading.value = true;
      error.value = null;

      final page = reset ? 1 : (currentPage.value + 1);
      final res = await _storeService.searchByPostcode(
        postcode: postcode,
        page: page,
        limit: pageSize.value,
      );

      currentPage.value = res.currentPage;
      totalPages.value = res.totalPages;

      if (reset) {
        stores.assignAll(res.data);
      } else {
        stores.addAll(res.data);
      }

      showingStores.value = true; // switch to stores view
    } catch (e) {
      error.value = e.toString();
      stores.clear();
      showingStores.value = false;
    } finally {
      loading.value = false;
    }
  }

  bool get canLoadMore =>
      showingStores.value &&
          currentPage.value < totalPages.value &&
          !loading.value;

  Future<void> loadMoreStores({required String postcode}) async {
    if (!canLoadMore) return;
    await _searchStoresByPostcode(postcode: postcode, reset: false);
  }

  // Example handler if you tap a store result
  void openStore(StoreItem s) {
    Get.toNamed(
      AppRoutes.storeDetails,
      arguments: {'store': s.toJson()},
    );
  }


}
