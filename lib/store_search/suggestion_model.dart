
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

  Map<String, dynamic> toJson() {
    return {
      'post_code': postCode,
      'admin_dis': adminDis,
    };
  }
}
