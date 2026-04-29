import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/category.dart';
import '../models/ingredient.dart';
import '../models/product.dart';
import '../models/store_profile.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

/// Lightweight in-memory cart line used while building an order.
class CartLine {
  final Product product;
  int quantity;

  CartLine({required this.product, this.quantity = 1});

  int get subtotal => product.price * quantity;
}

/// Single source of truth for the whole app.
///
/// Holds [products], [categories] and [transactions] in memory and persists
/// every mutation through [StorageService]. Also owns the in-progress [cart]
/// used by the order flow.
class AppState extends ChangeNotifier {
  AppState(this._storage) {
    _ingredients = _storage.loadIngredients();
    _products = _storage.loadProducts();
    _categories = _storage.loadCategories();
    _transactions = _storage.loadTransactions();
    _storeProfile = _storage.loadStoreProfile();
  }

  final StorageService _storage;
  final _uuid = const Uuid();

  late List<Ingredient> _ingredients;
  late List<Product> _products;
  late List<ProductCategory> _categories;
  late List<TransactionRecord> _transactions;
  StoreProfile _storeProfile = const StoreProfile();
  final List<CartLine> _cart = [];

  // ---------------- Getters ----------------

  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);
  List<Product> get products => List.unmodifiable(_products);
  List<ProductCategory> get categories => List.unmodifiable(_categories);
  List<TransactionRecord> get transactions {
    final sorted = [..._transactions]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  List<CartLine> get cart => List.unmodifiable(_cart);
  StoreProfile get storeProfile => _storeProfile;
  int get cartItemCount =>
      _cart.fold<int>(0, (sum, line) => sum + line.quantity);
  int get cartTotal => _cart.fold<int>(0, (sum, line) => sum + line.subtotal);

  ProductCategory? categoryById(String? id) {
    if (id == null) return null;
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<Product> productsByCategory(String? categoryId) {
    if (categoryId == null) return products;
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  // ---------------- Today's stats ----------------

  List<TransactionRecord> get todayTransactions {
    final now = DateTime.now();
    return _transactions.where((t) {
      return t.createdAt.year == now.year &&
          t.createdAt.month == now.month &&
          t.createdAt.day == now.day;
    }).toList();
  }

  int get todayRevenue =>
      todayTransactions.fold<int>(0, (sum, t) => sum + t.total);

  int get todayProfit =>
      todayTransactions.fold<int>(0, (sum, t) => sum + t.profit);

  int get todayCount => todayTransactions.length;

  // ---------------- Ingredients CRUD ----------------

  Future<void> addIngredient({
    required String name,
    required String unit,
    required int costPerUnit,
    required int stock,
  }) async {
    final ing = Ingredient(
      id: _uuid.v4(),
      name: name.trim(),
      unit: unit.trim(),
      costPerUnit: costPerUnit,
      stock: stock,
    );
    _ingredients = [..._ingredients, ing];
    await _storage.saveIngredients(_ingredients);
    notifyListeners();
  }

  Future<void> updateIngredient({
    required String id,
    required String name,
    required String unit,
    required int costPerUnit,
    required int stock,
  }) async {
    _ingredients = _ingredients.map((i) {
      if (i.id != id) return i;
      return i.copyWith(
        name: name.trim(),
        unit: unit.trim(),
        costPerUnit: costPerUnit,
        stock: stock,
      );
    }).toList();
    await _storage.saveIngredients(_ingredients);
    notifyListeners();
  }

  Future<void> deleteIngredient(String id) async {
    _ingredients = _ingredients.where((i) => i.id != id).toList();
    // Also remove this ingredient from any product recipes
    bool productsChanged = false;
    _products = _products.map((p) {
      if (p.recipe.any((r) => r.ingredientId == id)) {
        productsChanged = true;
        return p.copyWith(
          recipe: p.recipe.where((r) => r.ingredientId != id).toList(),
        );
      }
      return p;
    }).toList();

    await _storage.saveIngredients(_ingredients);
    if (productsChanged) {
      await _storage.saveProducts(_products);
    }
    notifyListeners();
  }

  // ---------------- Categories CRUD ----------------

  Future<void> addCategory(String name, {String? imageBase64}) async {
    final c = ProductCategory(
      id: _uuid.v4(),
      name: name.trim(),
      imageBase64: imageBase64,
    );
    _categories = [..._categories, c];
    await _storage.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> updateCategory(String id, String name, {String? imageBase64}) async {
    _categories = _categories
        .map((c) => c.id == id
            ? c.copyWith(name: name.trim(), imageBase64: imageBase64)
            : c)
        .toList();
    await _storage.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    _categories = _categories.where((c) => c.id != id).toList();
    // Detach products from the deleted category.
    _products = _products
        .map((p) => p.categoryId == id ? p.copyWith(categoryId: null) : p)
        .toList();
    await _storage.saveCategories(_categories);
    await _storage.saveProducts(_products);
    notifyListeners();
  }

  // ---------------- Store Profile ----------------

  Future<void> updateStoreProfile(StoreProfile profile) async {
    _storeProfile = profile;
    await _storage.saveStoreProfile(profile);
    notifyListeners();
  }

  // ---------------- Products CRUD ----------------

  Future<void> addProduct({
    required String name,
    required int price,
    String? categoryId,
    String? imageBase64,
    List<RecipeItem> recipe = const [],
    int? manualCost,
  }) async {
    final p = Product(
      id: _uuid.v4(),
      name: name.trim(),
      price: price,
      categoryId: categoryId,
      imageBase64: imageBase64,
      recipe: recipe,
      manualCost: manualCost,
    );
    _products = [..._products, p];
    await _storage.saveProducts(_products);
    notifyListeners();
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required int price,
    String? categoryId,
    String? imageBase64,
    List<RecipeItem>? recipe,
    int? manualCost,
  }) async {
    _products = _products.map((p) {
      if (p.id != id) return p;
      return p.copyWith(
        name: name.trim(),
        price: price,
        categoryId: categoryId,
        imageBase64: imageBase64,
        recipe: recipe ?? p.recipe,
        manualCost: manualCost ?? p.manualCost,
      );
    }).toList();
    await _storage.saveProducts(_products);
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    _products = _products.where((p) => p.id != id).toList();
    _cart.removeWhere((line) => line.product.id == id);
    await _storage.saveProducts(_products);
    notifyListeners();
  }

  // ---------------- Cart ----------------

  void addToCart(Product product) {
    final existingIndex =
        _cart.indexWhere((line) => line.product.id == product.id);
    if (existingIndex >= 0) {
      _cart[existingIndex].quantity++;
    } else {
      _cart.add(CartLine(product: product));
    }
    notifyListeners();
  }

  void incrementCartLine(String productId) {
    final idx = _cart.indexWhere((l) => l.product.id == productId);
    if (idx < 0) return;
    _cart[idx].quantity++;
    notifyListeners();
  }

  void decrementCartLine(String productId) {
    final idx = _cart.indexWhere((l) => l.product.id == productId);
    if (idx < 0) return;
    _cart[idx].quantity--;
    if (_cart[idx].quantity <= 0) {
      _cart.removeAt(idx);
    }
    notifyListeners();
  }

  void removeCartLine(String productId) {
    _cart.removeWhere((l) => l.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ---------------- Transactions ----------------

  int _processCheckoutStockAndCogs() {
    int totalCogs = 0;
    bool ingredientsChanged = false;

    for (final line in _cart) {
      int productCogs = 0;
      final product = line.product;
      final quantity = line.quantity;

      if (product.recipe.isNotEmpty) {
        // Calculate COGS from recipe and deduct stock
        for (final recipeItem in product.recipe) {
          final ingIndex = _ingredients.indexWhere((i) => i.id == recipeItem.ingredientId);
          if (ingIndex >= 0) {
            final ing = _ingredients[ingIndex];
            // Deduct stock
            final newStock = ing.stock - (recipeItem.quantity * quantity);
            _ingredients[ingIndex] = ing.copyWith(stock: newStock);
            ingredientsChanged = true;
            // Add to product COGS
            productCogs += (recipeItem.quantity * ing.costPerUnit);
          }
        }
      } else {
        // Use manual cost if recipe is empty
        productCogs = product.manualCost ?? 0;
      }
      totalCogs += (productCogs * quantity);
    }

    if (ingredientsChanged) {
      _storage.saveIngredients(_ingredients);
      // We don't necessarily need to notifyListeners immediately here as
      // the caller (checkoutCash/Qris) will do it.
    }

    return totalCogs;
  }

  Future<TransactionRecord> checkoutCash({required int paidAmount}) async {
    final total = cartTotal;
    final cogs = _processCheckoutStockAndCogs();
    
    final tx = TransactionRecord(
      id: _uuid.v4(),
      items: _cart
          .map((l) => TransactionItem(
                productId: l.product.id,
                productName: l.product.name,
                price: l.product.price,
                quantity: l.quantity,
              ))
          .toList(),
      total: total,
      cogs: cogs,
      paymentMethod: PaymentMethod.cash,
      paidAmount: paidAmount,
      change: paidAmount - total,
      createdAt: DateTime.now(),
    );
    _transactions = [..._transactions, tx];
    await _storage.saveTransactions(_transactions);
    _cart.clear();
    notifyListeners();
    return tx;
  }

  Future<TransactionRecord> checkoutQris({required String imageBase64}) async {
    final total = cartTotal;
    final cogs = _processCheckoutStockAndCogs();

    final tx = TransactionRecord(
      id: _uuid.v4(),
      items: _cart
          .map((l) => TransactionItem(
                productId: l.product.id,
                productName: l.product.name,
                price: l.product.price,
                quantity: l.quantity,
              ))
          .toList(),
      total: total,
      cogs: cogs,
      paymentMethod: PaymentMethod.qris,
      qrisImageBase64: imageBase64,
      createdAt: DateTime.now(),
    );
    _transactions = [..._transactions, tx];
    await _storage.saveTransactions(_transactions);
    _cart.clear();
    notifyListeners();
    return tx;
  }

  // ---------------- Maintenance ----------------

  Future<void> deleteAllTransactions() async {
    _transactions = [];
    await _storage.clearTransactions();
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _products = [];
    _categories = [];
    _transactions = [];
    _cart.clear();
    await _storage.clearAll();
    notifyListeners();
  }
}
