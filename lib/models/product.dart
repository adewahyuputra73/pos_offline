class Product {
  final String id;
  final String name;
  final int price;
  final String? categoryId;
  final String? imageBase64;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.categoryId,
    this.imageBase64,
  });

  Product copyWith({
    String? id,
    String? name,
    int? price,
    String? categoryId,
    String? imageBase64,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      imageBase64: imageBase64 ?? this.imageBase64,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'categoryId': categoryId,
        'imageBase64': imageBase64,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toInt(),
        categoryId: json['categoryId'] as String?,
        imageBase64: json['imageBase64'] as String?,
      );
}
