import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:dealzy/storage/token_storage.dart';

typedef TokenProvider = Future<String?> Function();

/// ─────────────────────────────────────────
/// 🟦 MODELS
/// ─────────────────────────────────────────

class OrderedItem {
  final String productId;
  final String productName;
  final String brand;
  final String model;
  final int quantity;
  final double rate;
  final String color;
  final String variant;
  final String imagePath;

  OrderedItem({
    required this.productId,
    required this.productName,
    required this.brand,
    required this.model,
    required this.quantity,
    required this.rate,
    required this.color,
    required this.variant,
    required this.imagePath,
  });

  factory OrderedItem.fromJson(Map<String, dynamic> json) => OrderedItem(
    productId: json['product_id'] ?? '',
    productName: json['product_name'] ?? '',
    brand: json['brand'] ?? '',
    model: json['model'] ?? '',
    quantity: int.tryParse(json['quantity'].toString()) ?? 0,
    rate: double.tryParse(json['rate'].toString()) ?? 0,
    color: json['color'] ?? '',
    variant: json['variant'] ?? '',
    imagePath: json['image_path'] ?? '',
  );
}

class Order {
  final String orderId;
  final String status;
  final String createdAt;
  final double subtotal;
  final double discount;
  final List<OrderedItem> items;

  Order({
    required this.orderId,
    required this.status,
    required this.createdAt,
    required this.subtotal,
    required this.discount,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    orderId: json['order_id'] ?? '',
    status: json['status'] ?? '',
    createdAt: json['created_at'] ?? '',
    subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
    discount: double.tryParse(json['discount'].toString()) ?? 0,
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => OrderedItem.fromJson(e))
        .toList(),
  );
}

class SellerOrders {
  final String sellerId;
  final String storeName;
  final String storeType;
  final String address;
  final String latitude;
  final String longitude;
  final String profilePath;
  final List<Order> orders;

  SellerOrders({
    required this.sellerId,
    required this.storeName,
    required this.storeType,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.profilePath,
    required this.orders,
  });

  factory SellerOrders.fromJson(Map<String, dynamic> json) => SellerOrders(
    sellerId: json['seller_id'] ?? '',
    storeName: json['store_name'] ?? '',
    storeType: json['store_type'] ?? '',
    address: json['address'] ?? '',
    latitude: json['lattitude'] ?? '',
    longitude: json['longtitude'] ?? '',
    profilePath: json['pro_path'] ?? '',
    orders: (json['orders'] as List<dynamic>? ?? [])
        .map((e) => Order.fromJson(e))
        .toList(),
  );
}

class CustomerOrdersResponse {
  final String status;
  final Pagination pagination;
  final List<SellerOrders> sellers;

  const CustomerOrdersResponse({
    required this.status,
    required this.pagination,
    required this.sellers,
  });

  bool get isSuccess => status.toLowerCase() == 'success';

  factory CustomerOrdersResponse.fromJson(Map<String, dynamic> json) =>
      CustomerOrdersResponse(
        status: json['status'] ?? '',
        pagination: Pagination.fromJson(json['pagination'] ?? {}),
        sellers: (json['orders_grouped_by_sellers'] as List<dynamic>? ?? [])
            .map((e) => SellerOrders.fromJson(e))
            .toList(),
      );
}

class Pagination {
  final int currentPage;
  final int perPage;
  final int totalOrders;
  final int totalPages;

  const Pagination({
    required this.currentPage,
    required this.perPage,
    required this.totalOrders,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json['current_page'] ?? 1,
    perPage: json['per_page'] ?? 10,
    totalOrders: json['total_orders'] ?? 0,
    totalPages: json['total_pages'] ?? 1,
  );
}

/// ─────────────────────────────────────────
/// 🟩 SERVICE CLASS
/// ─────────────────────────────────────────

class GetCustomerOrdersService {
  GetCustomerOrdersService({TokenProvider? getToken})
    : _getToken = getToken ?? TokenStorage.getToken,
      _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;
  final TokenProvider _getToken;

  /// ✅ Fetch orders by status ('pending', 'approved', 'complete')
  Future<CustomerOrdersResponse> getCustomerOrders({
    required String status,
    int page = 1,
    int limit = 10,
  }) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env file.');
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Not authenticated. Missing token.');
    }

    final uri = Uri.parse(
      '$_base/get_customer_orders.php?page=$page&limit=$limit&status=$status',
    );

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    final res = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final json = jsonDecode(res.body);
    final parsed = CustomerOrdersResponse.fromJson(testDATA);

    ///TODO : should be json used testdata as API NOT WORKING.

    if (!parsed.isSuccess) {
      throw Exception('Failed to fetch orders.');
    }

    return parsed;
  }

  /// ✅ Generate unique code for an order
  Future<String?> generateUnicode(String orderId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Missing bearer token.');
    }

    final uri = Uri.parse('$_base/generate_unicode.php');
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({"order_id": orderId});

    final res = await http
        .put(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final json = jsonDecode(res.body);
    if (json['status']?.toString().toLowerCase() != 'success') {
      throw Exception('Failed to generate code');
    }

    return json['code']?.toString();
  }
}

final testDATA = {
  "status": "success",
  "pagination": {
    "current_page": 1,
    "per_page": 10,
    "total_orders": 2,
    "total_pages": 1,
  },
  "orders_grouped_by_sellers": [
    {
      "seller_id": "23",
      "store_name": "new_enterprise",
      "store_type": "Retail",
      "address": "Any address",
      "lattitude": "51.501010",
      "longtitude": "-0.141563",
      "pro_path":
          "https://dealzyloop.com/api/upload/profiles/profile_68d4270969ef14.98874523.jpg",
      "orders": [
        {
          "order_id": "3",
          "status": "pending",
          "created_at": "2025-10-24 14:55:49",
          "items": [
            {
              "product_id": "37",
              "product_name": "Cucumber -1KG",
              "brand": "",
              "model": "",
              "quantity": 2,
              "rate": 1200,
              "color": "White",
              "variant": "Apple",
              "image_path":
                  "https://dealzyloop.com/api/upload/products/product_68d4272c935d75.07158427.jpg",
            },
            {
              "product_id": "39",
              "product_name": "Samsung  Galaxy S25",
              "brand": "Samsung",
              "model": "Galaxy S25",
              "quantity": 1,
              "rate": 2500,
              "color": "Black",
              "variant": "128GB",
              "image_path":
                  "https://dealzyloop.com/api/upload/products/product_68d4285e200479.78039190.png",
            },
          ],
          "subtotal": 4900,
          "discount": 50,
        },
        {
          "order_id": "4",
          "status": "pending",
          "created_at": "2025-10-24 17:10:48",
          "items": [
            {
              "product_id": "39",
              "product_name": "Samsung  Galaxy S25",
              "brand": "Samsung",
              "model": "Galaxy S25",
              "quantity": 1,
              "rate": 2500,
              "color": "Black",
              "variant": "128GB",
              "image_path":
                  "https://dealzyloop.com/api/upload/products/product_68d4285e200479.78039190.png",
            },
            {
              "product_id": "37",
              "product_name": "Cucumber -1KG",
              "brand": "",
              "model": "",
              "quantity": 2,
              "rate": 1200,
              "color": "White",
              "variant": "Apple",
              "image_path":
                  "https://dealzyloop.com/api/upload/products/product_68d4272c935d75.07158427.jpg",
            },
          ],
          "subtotal": 4900,
          "discount": 50,
        },
      ],
    },
  ],
};
