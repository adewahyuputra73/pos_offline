class Product {
  final String id;
  final String name;
  final int price;
  final String? categoryId;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.categoryId,
  });

  Product copyWith({
    String? id,
    String? name,
    int? price,
    String? categoryId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'categoryId': categoryId,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toInt(),
        categoryId: json['categoryId'] as String?,
      );
}
