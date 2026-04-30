import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/category.dart';
import '../models/ingredient.dart';
import '../models/product.dart';
import '../models/shift.dart';
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

/// Data class for HPP Summary
class ProductHppSummary {
  final String productId;
  final String productName;
  final int totalQuantitySold;
  final int totalRevenue;
  final int totalCogs;

  ProductHppSummary({
    required this.productId,
    required this.productName,
    required this.totalQuantitySold,
    required this.totalRevenue,
    required this.totalCogs,
  });

  int get totalProfit => totalRevenue - totalCogs;
  double get marginPercent => totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0.0;
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
    _shifts = _storage.loadShifts();
  }

  final StorageService _storage;
  final _uuid = const Uuid();

  late List<Ingredient> _ingredients;
  late List<Product> _products;
  late List<ProductCategory> _categories;
  late List<TransactionRecord> _transactions;
  late List<Shift> _shifts;
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
  
  int get cartTaxAmount => (cartTotal * (_storeProfile.taxRate / 100)).round();
  
  int get cartGrandTotal => cartTotal + cartTaxAmount;
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

  Ingredient? ingredientById(String id) {
    for (final i in _ingredients) {
      if (i.id == id) return i;
    }
    return null;
  }

  /// Ingredients with stock at or below threshold.
  List<Ingredient> lowStockIngredients({int threshold = 50}) {
    return _ingredients.where((i) => i.stock <= threshold).toList();
  }

  /// Check if all ingredients are sufficient for current cart.
  /// Returns list of ingredient names that are insufficient.
  List<String> get insufficientStockWarnings {
    // Accumulate total needed per ingredient across all cart lines
    final Map<String, int> needed = {};
    for (final line in _cart) {
      for (final r in line.product.recipe) {
        needed[r.ingredientId] = (needed[r.ingredientId] ?? 0) + (r.quantity * line.quantity);
      }
    }
    final warnings = <String>[];
    for (final entry in needed.entries) {
      final ing = ingredientById(entry.key);
      if (ing != null && ing.stock < entry.value) {
        final kurang = entry.value - ing.stock;
        warnings.add('${ing.name} kurang ${kurang} ${ing.unit}');
      }
    }
    return warnings;
  }

  // ---------------- Shift getters ----------------

  List<Shift> get shifts {
    final sorted = [..._shifts]
      ..sort((a, b) => b.openedAt.compareTo(a.openedAt));
    return List.unmodifiable(sorted);
  }

  /// Shift yang sedang aktif (belum ditutup), atau null.
  Shift? get activeShift =>
      _shifts.where((s) => s.isActive).firstOrNull;

  bool get hasActiveShift => activeShift != null;

  /// Transaksi milik shift tertentu (berdasarkan rentang waktu).
  List<TransactionRecord> transactionsForShift(Shift shift) {
    final end = shift.closedAt ?? DateTime.now();
    return _transactions.where((t) {
      return !t.createdAt.isBefore(shift.openedAt) &&
          !t.createdAt.isAfter(end);
    }).toList();
  }

  /// Stats realtime untuk shift aktif.
  int get activeShiftTransactionCount {
    final s = activeShift;
    if (s == null) return 0;
    return transactionsForShift(s).length;
  }

  int get activeShiftRevenue {
    final s = activeShift;
    if (s == null) return 0;
    return transactionsForShift(s).fold(0, (sum, t) => sum + t.total);
  }

  int get activeShiftCashRevenue {
    final s = activeShift;
    if (s == null) return 0;
    return transactionsForShift(s)
        .where((t) => t.paymentMethod == PaymentMethod.cash)
        .fold(0, (sum, t) => sum + t.total);
  }

  int get activeShiftQrisRevenue {
    final s = activeShift;
    if (s == null) return 0;
    return transactionsForShift(s)
        .where((t) => t.paymentMethod == PaymentMethod.qris)
        .fold(0, (sum, t) => sum + t.total);
  }

  int get activeShiftTax {
    final s = activeShift;
    if (s == null) return 0;
    return transactionsForShift(s).fold(0, (sum, t) => sum + t.taxAmount);
  }

  /// Estimasi uang di laci kas: modal awal + semua pendapatan tunai.
  int get activeShiftExpectedCash {
    final s = activeShift;
    if (s == null) return 0;
    return s.openingCash + activeShiftCashRevenue;
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

  int get todayNetSales =>
      todayTransactions.fold<int>(0, (sum, t) => sum + (t.total - t.taxAmount));

  int get todayTax =>
      todayTransactions.fold<int>(0, (sum, t) => sum + t.taxAmount);

  int get todayCogs =>
      todayTransactions.fold<int>(0, (sum, t) => sum + t.cogs);

  int get todayProfit =>
      todayTransactions.fold<int>(0, (sum, t) => sum + t.profit);

  int get todayCount => todayTransactions.length;

  // ---------------- HPP Analytics ----------------

  int cogsForProduct(Product product) {
    if (product.recipe.isNotEmpty) {
      int cogs = 0;
      for (final recipeItem in product.recipe) {
        final ing = ingredientById(recipeItem.ingredientId);
        if (ing != null) {
          cogs += recipeItem.quantity * ing.costPerUnit;
        }
      }
      return cogs;
    }
    return product.manualCost ?? 0;
  }

  Map<String, ProductHppSummary> hppReport({DateTime? from, DateTime? to}) {
    final Map<String, ProductHppSummary> map = {};

    for (final t in _transactions) {
      if (from != null && t.createdAt.isBefore(from)) continue;
      if (to != null && t.createdAt.isAfter(to)) continue;

      for (final item in t.items) {
        final existing = map[item.productId];
        final revenue = item.subtotal;
        
        // Use stored cogsPerUnit if available (from new transactions),
        // otherwise calculate current cogs using product recipe (for old transactions)
        int itemCogs = 0;
        if (item.cogsPerUnit > 0) {
          itemCogs = item.totalCogs;
        } else {
          final product = _products.where((p) => p.id == item.productId).firstOrNull;
          int cogsPerUnit = product != null ? cogsForProduct(product) : 0;
          itemCogs = cogsPerUnit * item.quantity;
        }

        if (existing == null) {
          map[item.productId] = ProductHppSummary(
            productId: item.productId,
            productName: item.productName,
            totalQuantitySold: item.quantity,
            totalRevenue: revenue,
            totalCogs: itemCogs,
          );
        } else {
          map[item.productId] = ProductHppSummary(
            productId: item.productId,
            productName: item.productName,
            totalQuantitySold: existing.totalQuantitySold + item.quantity,
            totalRevenue: existing.totalRevenue + revenue,
            totalCogs: existing.totalCogs + itemCogs,
          );
        }
      }
    }
    return map;
  }

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

  List<int> _processCheckoutStockAndCogs() {
    List<int> itemCogs = [];
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
      itemCogs.add(productCogs);
    }

    if (ingredientsChanged) {
      _storage.saveIngredients(_ingredients);
      // We don't necessarily need to notifyListeners immediately here as
      // the caller (checkoutCash/Qris) will do it.
    }

    return itemCogs;
  }

  Future<TransactionRecord> checkoutCash({required int paidAmount}) async {
    final total = cartGrandTotal;
    final taxAmount = cartTaxAmount;
    final itemCogs = _processCheckoutStockAndCogs();
    final cashierName = activeShift?.cashierName ?? '';

    int totalCogs = 0;
    for (int i = 0; i < _cart.length; i++) {
      totalCogs += itemCogs[i] * _cart[i].quantity;
    }

    final tx = TransactionRecord(
      id: _uuid.v4(),
      items: _cart.asMap().entries.map((entry) {
        final i = entry.key;
        final l = entry.value;
        return TransactionItem(
          productId: l.product.id,
          productName: l.product.name,
          price: l.product.price,
          quantity: l.quantity,
          cogsPerUnit: itemCogs[i],
        );
      }).toList(),
      total: total,
      cogs: totalCogs,
      taxAmount: taxAmount,
      paymentMethod: PaymentMethod.cash,
      paidAmount: paidAmount,
      change: paidAmount - total,
      createdAt: DateTime.now(),
      cashierName: cashierName,
    );
    _transactions = [..._transactions, tx];
    await _storage.saveTransactions(_transactions);
    _cart.clear();
    notifyListeners();
    return tx;
  }

  Future<TransactionRecord> checkoutQris({required String imageBase64}) async {
    final total = cartGrandTotal;
    final taxAmount = cartTaxAmount;
    final itemCogs = _processCheckoutStockAndCogs();
    final cashierName = activeShift?.cashierName ?? '';

    int totalCogs = 0;
    for (int i = 0; i < _cart.length; i++) {
      totalCogs += itemCogs[i] * _cart[i].quantity;
    }

    final tx = TransactionRecord(
      id: _uuid.v4(),
      items: _cart.asMap().entries.map((entry) {
        final i = entry.key;
        final l = entry.value;
        return TransactionItem(
          productId: l.product.id,
          productName: l.product.name,
          price: l.product.price,
          quantity: l.quantity,
          cogsPerUnit: itemCogs[i],
        );
      }).toList(),
      total: total,
      cogs: totalCogs,
      taxAmount: taxAmount,
      paymentMethod: PaymentMethod.qris,
      qrisImageBase64: imageBase64,
      createdAt: DateTime.now(),
      cashierName: cashierName,
    );
    _transactions = [..._transactions, tx];
    await _storage.saveTransactions(_transactions);
    _cart.clear();
    notifyListeners();
    return tx;
  }

  // ---------------- Shift Management ----------------

  Future<Shift> openShift({
    required String cashierName,
    required int openingCash,
  }) async {
    // Pastikan tidak ada shift aktif lainnya
    if (hasActiveShift) {
      throw StateError('Masih ada shift aktif. Tutup shift sekarang sebelum membuka yang baru.');
    }
    final shift = Shift(
      id: _uuid.v4(),
      cashierName: cashierName.trim().isEmpty ? 'Kasir' : cashierName.trim(),
      openingCash: openingCash,
      openedAt: DateTime.now(),
    );
    _shifts = [..._shifts, shift];
    await _storage.saveShifts(_shifts);
    notifyListeners();
    return shift;
  }

  Future<Shift> closeShift({
    required int closingCash,
    String? notes,
  }) async {
    final active = activeShift;
    if (active == null) throw StateError('Tidak ada shift aktif.');

    final txs = transactionsForShift(active);
    final rev = txs.fold<int>(0, (s, t) => s + t.total);
    final cashRev = txs
        .where((t) => t.paymentMethod == PaymentMethod.cash)
        .fold<int>(0, (s, t) => s + t.total);
    final qrisRev = txs
        .where((t) => t.paymentMethod == PaymentMethod.qris)
        .fold<int>(0, (s, t) => s + t.total);
    final tax = txs.fold<int>(0, (s, t) => s + t.taxAmount);

    final closed = active.copyWith(
      closingCash: closingCash,
      closedAt: DateTime.now(),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      snapshotTransactions: txs.length,
      snapshotRevenue: rev,
      snapshotCash: cashRev,
      snapshotQris: qrisRev,
      snapshotTax: tax,
    );

    _shifts = _shifts.map((s) => s.id == active.id ? closed : s).toList();
    await _storage.saveShifts(_shifts);
    notifyListeners();
    return closed;
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
