/// Renamed from `Category` to avoid clashing with the
/// `@Category(...)` annotation in `package:flutter/foundation.dart`.
class ProductCategory {
  final String id;
  final String name;
  final String? imageBase64;

  const ProductCategory({
    required this.id,
    required this.name,
    this.imageBase64,
  });

  ProductCategory copyWith({String? id, String? name, String? imageBase64}) {
    return ProductCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      imageBase64: imageBase64 ?? this.imageBase64,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageBase64': imageBase64,
      };

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      ProductCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        imageBase64: json['imageBase64'] as String?,
      );
}
