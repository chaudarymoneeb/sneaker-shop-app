class ShoeModel {
  const ShoeModel({
    required this.id,
    required this.name,
    required this.price,
    this.brand = 'Shoe App',
    this.imageUrl = '',
    this.images = const [],
    this.category = 'Lifestyle',
    this.rating = 0,
    this.description = '',
    this.sizes = const [],
    this.colorImageMap = const {},
  });

  final String id;
  final String name;
  final double price;
  final String brand;
  final String imageUrl;
  final List<String> images;
  final String category;
  final double rating;
  final String description;
  final List<String> sizes;
  final Map<String, String> colorImageMap;

  factory ShoeModel.fromMap(Map<String, dynamic> map) {
    final imageList =
        (map['images'] as List?)?.cast<String>() ??
        (map['image_url'] == null ? <String>[] : [map['image_url'] as String]);
    return ShoeModel(
      id: map['id'].toString(),
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      brand: map['brand'] as String? ?? 'Shoe App',
      imageUrl: map['image_url'] as String? ?? imageList.firstOrNull ?? '',
      images: imageList,
      category: map['category'] as String? ?? 'Lifestyle',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      description: map['description'] as String? ?? '',
      sizes:
          (map['sizes'] as List?)?.map((size) => size.toString()).toList() ??
          const [],
      colorImageMap: ((map['color_image_map'] as Map?) ?? const {}).map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
    );
  }
}
