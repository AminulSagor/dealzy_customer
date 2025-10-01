
class StoreItem {
  final String id;
  final String name;
  final String type;
  final String address;
  final String image;
  final String opening;
  final String closing;
  final String phone;

  StoreItem({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.image,
    required this.opening,
    required this.closing,
    required this.phone,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['store_id']?.toString() ?? '',
      name: json['store_name']?.toString() ?? '',
      type: json['store_type']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      image: json['image_path']?.toString() ?? '',
      opening: json['opening_time']?.toString() ?? '',
      closing: json['closing_time']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'store_id': id,
    'store_name': name,
    'store_type': type,
    'address': address,
    'image_path': image,
    'opening_time': opening,
    'closing_time': closing,
    'phone': phone,
  };
}
