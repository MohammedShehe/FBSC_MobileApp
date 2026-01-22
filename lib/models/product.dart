class ProductSize {
  final int? id;
  final String code;
  final String sizeLabel;
  final int? stock;

  ProductSize({
    this.id,
    required this.code,
    required this.sizeLabel,
    this.stock,
  });

  factory ProductSize.fromJson(Map<String, dynamic> json) {
    return ProductSize(
      id: json['id'],
      code: json['code'] ?? json['size_label'] ?? '',
      sizeLabel: json['size_label'] ?? json['code'] ?? '',
      stock: json['stock'],
    );
  }

  String get cleanSize {
    return code
        .replaceAll(RegExp(r'EU', caseSensitive: false), '')
        .replaceAll(RegExp(r'saizi', caseSensitive: false), '')
        .replaceAll(RegExp(r'size', caseSensitive: false), '')
        .trim();
  }
}

class Product {
  final int id;
  final String name;
  final String company;
  final String color;
  final String type;
  final double price;
  final double discountPercent;
  final double finalPrice;
  final int totalStock;
  final String description;
  final List<String> images;
  final List<ProductSize> sizes;
  final DateTime createdAt;
  final double rating;
  final int ratingCount;

  Product({
    required this.id,
    required this.name,
    required this.company,
    required this.color,
    required this.type,
    required this.price,
    required this.discountPercent,
    required this.finalPrice,
    required this.totalStock,
    required this.description,
    required this.images,
    required this.sizes,
    required this.createdAt,
    this.rating = 0.0,
    this.ratingCount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final sizes = (json['sizes'] as List? ?? []).map((size) {
      return ProductSize.fromJson(size);
    }).toList();

    final totalStock = sizes.fold(0, (sum, size) => sum + (size.stock ?? 0));

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Bidhaa Bila Jina',
      company: json['company'] ?? 'Hakuna Chapa',
      color: json['color'] ?? 'Hakuna Rangi',
      type: json['type'] ?? 'Hakuna Aina',
      price: (json['price'] ?? 0).toDouble(),
      discountPercent: (json['discount_percent'] ?? 0).toDouble(),
      finalPrice: (json['final_price'] ?? json['price'] ?? 0).toDouble(),
      totalStock: totalStock,
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      sizes: sizes,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      rating: (json['avg_rating'] ?? 0).toDouble(),
      ratingCount: json['total_ratings'] ?? 0,
    );
  }

  bool get hasStock => totalStock > 0;
  bool get hasDiscount => discountPercent > 0;
  String get formattedPrice => 'TZS ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  String get formattedFinalPrice => 'TZS ${finalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
}