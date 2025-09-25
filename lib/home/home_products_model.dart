class HomeProductDto {
  final String id;
  final String name;
  final String price;       // API sends strings
  final String? offerPrice; // nullable
  final String? expiryDate; // nullable (ISO or null)
  final String imagePath;

  HomeProductDto({
    required this.id,
    required this.name,
    required this.price,
    required this.offerPrice,
    required this.expiryDate,
    required this.imagePath,
  });

  factory HomeProductDto.fromJson(Map<String, dynamic> j) => HomeProductDto(
    id: j['product_id']?.toString() ?? '',
    name: j['product_name']?.toString() ?? '',
    price: j['price']?.toString() ?? '0',
    offerPrice: j['offer_price']?.toString(),
    expiryDate: j['expiry_date']?.toString(),
    imagePath: j['image_path']?.toString() ?? '',
  );
}

class HomeProductsResponse {
  final String status;
  final int page;
  final int limit;
  final int totalRecords;
  final int totalPages;
  final List<HomeProductDto> products;

  HomeProductsResponse({
    required this.status,
    required this.page,
    required this.limit,
    required this.totalRecords,
    required this.totalPages,
    required this.products,
  });

  factory HomeProductsResponse.fromJson(Map<String, dynamic> j) =>
      HomeProductsResponse(
        status: j['status']?.toString() ?? 'error',
        page: int.tryParse('${j['page']}') ?? 1,
        limit: int.tryParse('${j['limit']}') ?? 0,
        totalRecords: int.tryParse('${j['total_records']}') ?? 0,
        totalPages: int.tryParse('${j['total_pages']}') ?? 0,
        products: (j['products'] as List<dynamic>? ?? [])
            .map((e) => HomeProductDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
