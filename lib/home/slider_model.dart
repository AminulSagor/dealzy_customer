class SliderDto {
  final String imageUrl;

  SliderDto({required this.imageUrl});

  factory SliderDto.fromJson(Map<String, dynamic> j) => SliderDto(
    imageUrl: j['image_url']?.toString() ?? '',
  );
}

class SliderApiResponse {
  final String status;
  final List<SliderDto> sliders;

  SliderApiResponse({required this.status, required this.sliders});

  factory SliderApiResponse.fromJson(Map<String, dynamic> j) =>
      SliderApiResponse(
        status: j['status']?.toString() ?? 'error',
        sliders: (j['sliders'] as List<dynamic>? ?? [])
            .map((e) => SliderDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
