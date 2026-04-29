class RecipeItem {
  final String ingredientId;
  final int quantity; // amount needed in the ingredient's unit

  const RecipeItem({
    required this.ingredientId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'ingredientId': ingredientId,
        'quantity': quantity,
      };

  factory RecipeItem.fromJson(Map<String, dynamic> json) => RecipeItem(
        ingredientId: json['ingredientId'] as String,
        quantity: (json['quantity'] as num).toInt(),
      );
}

class Product {
  final String id;
  final String name;
  final int price;
  final String? categoryId;
  final String? imageBase64;
  final List<RecipeItem> recipe;
  final int? manualCost; // used if recipe is empty

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.categoryId,
    this.imageBase64,
    this.recipe = const [],
    this.manualCost,
  });

  Product copyWith({
    String? id,
    String? name,
    int? price,
    String? categoryId,
    String? imageBase64,
    List<RecipeItem>? recipe,
    int? manualCost,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      imageBase64: imageBase64 ?? this.imageBase64,
      recipe: recipe ?? this.recipe,
      manualCost: manualCost ?? this.manualCost,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'categoryId': categoryId,
        'imageBase64': imageBase64,
        'recipe': recipe.map((r) => r.toJson()).toList(),
        'manualCost': manualCost,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toInt(),
        categoryId: json['categoryId'] as String?,
        imageBase64: json['imageBase64'] as String?,
        recipe: (json['recipe'] as List<dynamic>?)
                ?.map((e) => RecipeItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        manualCost: (json['manualCost'] as num?)?.toInt(),
      );
}
