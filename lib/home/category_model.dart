
class CategoryDto {
  final String id;
  final String category;
  final String imgPath;

  CategoryDto({
    required this.id,
    required this.category,
    required this.imgPath,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> j) => CategoryDto(
    id: j['id']?.toString() ?? '',
    category: j['category']?.toString() ?? '',
    imgPath: j['img_path']?.toString() ?? '',
  );
}

class CategoryApiResponse {
  final String status;
  final List<CategoryDto> categories;

  CategoryApiResponse({
    required this.status,
    required this.categories,
  });

  factory CategoryApiResponse.fromJson(Map<String, dynamic> j) =>
      CategoryApiResponse(
        status: j['status']?.toString() ?? 'error',
        categories: (j['categories'] as List<dynamic>? ?? [])
            .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
