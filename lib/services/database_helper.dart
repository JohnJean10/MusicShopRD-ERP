import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static SharedPreferences? _prefs;
  
  static const String _productsKey = 'products_data';
  static const String _ordersKey = 'orders_data';
  static const String _customersKey = 'customers_data';
  static const String _suppliersKey = 'suppliers_data';
  
  DbHelper._init();

  Future<SharedPreferences> get database async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Products CRUD
  Future<void> insertProduct(Map<String, dynamic> row) async {
    final prefs = await database;
    final products = await fetchProducts();
    
    final existingIndex = products.indexWhere((p) => p['sku'] == row['sku']);
    if (existingIndex >= 0) {
      products[existingIndex] = row;
    } else {
      products.add(row);
    }
    
    await prefs.setString(_productsKey, jsonEncode(products));
  }

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final prefs = await database;
    final data = prefs.getString(_productsKey);
    if (data == null || data.isEmpty) return [];
    
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> deleteProduct(String sku) async {
    final prefs = await database;
    final products = await fetchProducts();
    products.removeWhere((p) => p['sku'] == sku);
    await prefs.setString(_productsKey, jsonEncode(products));
  }

  Future<void> updateProduct(String sku, Map<String, dynamic> row) async {
    final prefs = await database;
    final products = await fetchProducts();
    final index = products.indexWhere((p) => p['sku'] == sku);
    if (index >= 0) {
      products[index] = row;
      await prefs.setString(_productsKey, jsonEncode(products));
    }
  }

  // Orders CRUD
  Future<void> insertOrder(Map<String, dynamic> row) async {
    final prefs = await database;
    final orders = await fetchOrders();
    
    final existingIndex = orders.indexWhere((o) => o['id'] == row['id']);
    if (existingIndex >= 0) {
      orders[existingIndex] = row;
    } else {
      orders.add(row);
    }
    
    await prefs.setString(_ordersKey, jsonEncode(orders));
  }

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final prefs = await database;
    final data = prefs.getString(_ordersKey);
    if (data == null || data.isEmpty) return [];
    
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> updateOrder(String id, Map<String, dynamic> row) async {
    final prefs = await database;
    final orders = await fetchOrders();
    final index = orders.indexWhere((o) => o['id'] == id);
    if (index >= 0) {
      orders[index] = row;
      await prefs.setString(_ordersKey, jsonEncode(orders));
    }
  }

  Future<void> deleteOrder(String id) async {
    final prefs = await database;
    final orders = await fetchOrders();
    orders.removeWhere((o) => o['id'] == id);
    await prefs.setString(_ordersKey, jsonEncode(orders));
  }

  // Customers CRUD
  Future<void> insertCustomer(Map<String, dynamic> row) async {
    final prefs = await database;
    final customers = await fetchCustomers();
    
    final existingIndex = customers.indexWhere((c) => c['id'] == row['id']);
    if (existingIndex >= 0) {
      customers[existingIndex] = row;
    } else {
      customers.add(row);
    }
    
    await prefs.setString(_customersKey, jsonEncode(customers));
  }

  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    final prefs = await database;
    final data = prefs.getString(_customersKey);
    if (data == null || data.isEmpty) return [];
    
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> updateCustomer(String id, Map<String, dynamic> row) async {
    final prefs = await database;
    final customers = await fetchCustomers();
    final index = customers.indexWhere((c) => c['id'] == id);
    if (index >= 0) {
      customers[index] = row;
      await prefs.setString(_customersKey, jsonEncode(customers));
    }
  }

  Future<void> deleteCustomer(String id) async {
    final prefs = await database;
    final customers = await fetchCustomers();
    customers.removeWhere((c) => c['id'] == id);
    await prefs.setString(_customersKey, jsonEncode(customers));
  }

  // Suppliers CRUD
  Future<void> insertSupplier(Map<String, dynamic> row) async {
    final prefs = await database;
    final suppliers = await fetchSuppliers();
    
    final existingIndex = suppliers.indexWhere((s) => s['id'] == row['id']);
    if (existingIndex >= 0) {
      suppliers[existingIndex] = row;
    } else {
      suppliers.add(row);
    }
    
    await prefs.setString(_suppliersKey, jsonEncode(suppliers));
  }

  Future<List<Map<String, dynamic>>> fetchSuppliers() async {
    final prefs = await database;
    final data = prefs.getString(_suppliersKey);
    if (data == null || data.isEmpty) return [];
    
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> updateSupplier(String id, Map<String, dynamic> row) async {
    final prefs = await database;
    final suppliers = await fetchSuppliers();
    final index = suppliers.indexWhere((s) => s['id'] == id);
    if (index >= 0) {
      suppliers[index] = row;
      await prefs.setString(_suppliersKey, jsonEncode(suppliers));
    }
  }

  Future<void> deleteSupplier(String id) async {
    final prefs = await database;
    final suppliers = await fetchSuppliers();
    suppliers.removeWhere((s) => s['id'] == id);
    await prefs.setString(_suppliersKey, jsonEncode(suppliers));
  }
}
