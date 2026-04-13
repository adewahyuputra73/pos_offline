import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/category.dart';
import '../models/product.dart';
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
    _products = _storage.loadProducts();
    _categories = _storage.loadCategories();
    _transactions = _storage.loadTransactions();
  }

  final StorageService _storage;
  final _uuid = const Uuid();

  late List<Product> _products;
  late List<ProductCategory> _categories;
  late List<TransactionRecord> _transactions;
  final List<CartLine> _cart = [];

  // ---------------- Getters ----------------

  List<Product> get products => List.unmodifiable(_products);
  List<ProductCategory> get categories => List.unmodifiable(_categories);
  List<TransactionRecord> get transactions {
    final sorted = [..._transactions]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  List<CartLine> get cart => List.unmodifiable(_cart);
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

  int get todayCount => todayTransactions.length;

  // ---------------- Categories CRUD ----------------

  Future<void> addCategory(String name) async {
    final c = ProductCategory(id: _uuid.v4(), name: name.trim());
    _categories = [..._categories, c];
    await _storage.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> updateCategory(String id, String name) async {
    _categories = _categories
        .map((c) => c.id == id ? c.copyWith(name: name.trim()) : c)
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

  // ---------------- Products CRUD ----------------

  Future<void> addProduct({
    required String name,
    required int price,
    String? categoryId,
  }) async {
    final p = Product(
      id: _uuid.v4(),
      name: name.trim(),
      price: price,
      categoryId: categoryId,
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
  }) async {
    _products = _products.map((p) {
      if (p.id != id) return p;
      return p.copyWith(name: name.trim(), price: price, categoryId: categoryId);
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

  Future<TransactionRecord> checkoutCash({required int paidAmount}) async {
    final total = cartTotal;
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
