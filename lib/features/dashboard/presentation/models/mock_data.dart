import 'package:flutter/material.dart';

/// Temporary UI-only data + sample values for the cashier dashboard.
///
/// These classes live ONLY in the presentation layer on purpose — they
/// are NOT domain entities. Once the Domain + Data layers are built,
/// this file will be deleted and the widgets will consume real entities
/// through a @riverpod controller.
class MockCategory {
  final String id;
  final String name;
  final IconData icon;

  const MockCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class MockProduct {
  final String id;
  final String name;
  final String categoryId;
  final double price;
  final IconData icon;
  final Color accent;
  final int stock;

  const MockProduct({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.icon,
    required this.accent,
    required this.stock,
  });
}

class MockCartLine {
  final MockProduct product;
  int quantity;

  MockCartLine({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

const List<MockCategory> mockCategories = [
  MockCategory(id: 'all', name: 'Semua', icon: Icons.apps_rounded),
  MockCategory(id: 'coffee', name: 'Kopi', icon: Icons.coffee_rounded),
  MockCategory(
    id: 'tea',
    name: 'Teh',
    icon: Icons.emoji_food_beverage_rounded,
  ),
  MockCategory(id: 'snack', name: 'Snack', icon: Icons.cookie_rounded),
  MockCategory(id: 'meals', name: 'Makanan', icon: Icons.restaurant_rounded),
  MockCategory(id: 'dessert', name: 'Dessert', icon: Icons.icecream_rounded),
];

const List<MockProduct> mockProducts = [
  MockProduct(
    id: 'p1',
    name: 'Espresso',
    categoryId: 'coffee',
    price: 18000,
    icon: Icons.coffee_rounded,
    accent: Color(0xFF6F4E37),
    stock: 24,
  ),
  MockProduct(
    id: 'p2',
    name: 'Cappuccino',
    categoryId: 'coffee',
    price: 25000,
    icon: Icons.local_cafe_rounded,
    accent: Color(0xFFC68E47),
    stock: 18,
  ),
  MockProduct(
    id: 'p3',
    name: 'Cafe Latte',
    categoryId: 'coffee',
    price: 27000,
    icon: Icons.coffee_maker_rounded,
    accent: Color(0xFFB5835A),
    stock: 15,
  ),
  MockProduct(
    id: 'p4',
    name: 'Americano',
    categoryId: 'coffee',
    price: 20000,
    icon: Icons.coffee_rounded,
    accent: Color(0xFF4B2E1E),
    stock: 20,
  ),
  MockProduct(
    id: 'p5',
    name: 'Matcha Latte',
    categoryId: 'tea',
    price: 28000,
    icon: Icons.emoji_food_beverage_rounded,
    accent: Color(0xFF6B8E23),
    stock: 10,
  ),
  MockProduct(
    id: 'p6',
    name: 'Teh Tarik',
    categoryId: 'tea',
    price: 15000,
    icon: Icons.emoji_food_beverage_rounded,
    accent: Color(0xFFA0522D),
    stock: 30,
  ),
  MockProduct(
    id: 'p7',
    name: 'Lemon Tea',
    categoryId: 'tea',
    price: 16000,
    icon: Icons.local_drink_rounded,
    accent: Color(0xFFDAA520),
    stock: 22,
  ),
  MockProduct(
    id: 'p8',
    name: 'Croissant',
    categoryId: 'snack',
    price: 22000,
    icon: Icons.bakery_dining_rounded,
    accent: Color(0xFFD2A373),
    stock: 8,
  ),
  MockProduct(
    id: 'p9',
    name: 'Choco Cookie',
    categoryId: 'snack',
    price: 12000,
    icon: Icons.cookie_rounded,
    accent: Color(0xFF8B4513),
    stock: 40,
  ),
  MockProduct(
    id: 'p10',
    name: 'Nasi Goreng',
    categoryId: 'meals',
    price: 32000,
    icon: Icons.rice_bowl_rounded,
    accent: Color(0xFFCC6600),
    stock: 12,
  ),
  MockProduct(
    id: 'p11',
    name: 'Mie Ayam',
    categoryId: 'meals',
    price: 28000,
    icon: Icons.ramen_dining_rounded,
    accent: Color(0xFFBF6F3A),
    stock: 14,
  ),
  MockProduct(
    id: 'p12',
    name: 'Tiramisu',
    categoryId: 'dessert',
    price: 35000,
    icon: Icons.cake_rounded,
    accent: Color(0xFF8B5E3C),
    stock: 6,
  ),
  MockProduct(
    id: 'p13',
    name: 'Brownies',
    categoryId: 'dessert',
    price: 24000,
    icon: Icons.cake_rounded,
    accent: Color(0xFF5D3A1A),
    stock: 0,
  ),
  MockProduct(
    id: 'p14',
    name: 'Gelato',
    categoryId: 'dessert',
    price: 30000,
    icon: Icons.icecream_rounded,
    accent: Color(0xFFE8B98B),
    stock: 9,
  ),
];

/// Lightweight Rupiah formatter — no external dep needed for mock data.
String formatRupiah(num amount) {
  final s = amount.toStringAsFixed(0);
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final remain = s.length - i;
    buf.write(s[i]);
    if (remain > 1 && remain % 3 == 1) buf.write('.');
  }
  return 'Rp ${buf.toString()}';
}
