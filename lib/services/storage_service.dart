import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';
import '../models/ingredient.dart';
import '../models/product.dart';
import '../models/store_profile.dart';
import '../models/transaction.dart';

/// Persistent storage backed by [SharedPreferences].
///
/// Each entity collection is stored as a JSON-encoded list under a stable key.
/// Designed to be small, simple and offline-first — no DB engine required.
class StorageService {
  static const _kIngredients = 'border_po.ingredients';
  static const _kProducts = 'border_po.products';
  static const _kCategories = 'border_po.categories';
  static const _kTransactions = 'border_po.transactions';
  static const _kStoreProfile = 'border_po.store_profile';

  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  // ---------------- Ingredients ----------------

  List<Ingredient> loadIngredients() {
    final raw = _prefs.getString(_kIngredients);
    if (raw == null || raw.isEmpty) return <Ingredient>[];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveIngredients(List<Ingredient> ingredients) async {
    final raw = jsonEncode(ingredients.map((e) => e.toJson()).toList());
    await _prefs.setString(_kIngredients, raw);
  }

  // ---------------- Products ----------------

  List<Product> loadProducts() {
    final raw = _prefs.getString(_kProducts);
    if (raw == null || raw.isEmpty) return <Product>[];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProducts(List<Product> products) async {
    final raw = jsonEncode(products.map((e) => e.toJson()).toList());
    await _prefs.setString(_kProducts, raw);
  }

  // ---------------- Categories ----------------

  List<ProductCategory> loadCategories() {
    final raw = _prefs.getString(_kCategories);
    if (raw == null || raw.isEmpty) return <ProductCategory>[];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCategories(List<ProductCategory> categories) async {
    final raw = jsonEncode(categories.map((e) => e.toJson()).toList());
    await _prefs.setString(_kCategories, raw);
  }

  // ---------------- Transactions ----------------

  List<TransactionRecord> loadTransactions() {
    final raw = _prefs.getString(_kTransactions);
    if (raw == null || raw.isEmpty) return <TransactionRecord>[];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => TransactionRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTransactions(List<TransactionRecord> txs) async {
    final raw = jsonEncode(txs.map((e) => e.toJson()).toList());
    await _prefs.setString(_kTransactions, raw);
  }

  // ---------------- Maintenance ----------------

  Future<void> clearTransactions() async {
    await _prefs.remove(_kTransactions);
  }

  Future<void> clearAll() async {
    await _prefs.remove(_kIngredients);
    await _prefs.remove(_kProducts);
    await _prefs.remove(_kCategories);
    await _prefs.remove(_kTransactions);
    await _prefs.remove(_kStoreProfile);
  }

  // ---------------- Store Profile ----------------

  StoreProfile loadStoreProfile() {
    final raw = _prefs.getString(_kStoreProfile);
    if (raw == null || raw.isEmpty) return const StoreProfile();
    return StoreProfile.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> saveStoreProfile(StoreProfile profile) async {
    final raw = jsonEncode(profile.toJson());
    await _prefs.setString(_kStoreProfile, raw);
  }
}
