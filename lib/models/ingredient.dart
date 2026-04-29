/// Model untuk bahan baku (Raw Material).
class Ingredient {
  final String id;
  final String name;
  final String unit; // e.g. gram, ml, pcs
  final int costPerUnit; // e.g. Rp 20 per gram
  final int stock; // current stock quantity in [unit]

  const Ingredient({
    required this.id,
    required this.name,
    required this.unit,
    required this.costPerUnit,
    required this.stock,
  });

  Ingredient copyWith({
    String? id,
    String? name,
    String? unit,
    int? costPerUnit,
    int? stock,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      stock: stock ?? this.stock,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit': unit,
        'costPerUnit': costPerUnit,
        'stock': stock,
      };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        id: json['id'] as String,
        name: json['name'] as String,
        unit: json['unit'] as String,
        costPerUnit: (json['costPerUnit'] as num).toInt(),
        stock: (json['stock'] as num).toInt(),
      );
}
