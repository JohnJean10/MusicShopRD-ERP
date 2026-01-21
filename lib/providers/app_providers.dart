import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/customer.dart';
import '../models/supplier.dart';
import '../services/database_helper.dart';

// ============= Config State =============

class AppConfigState {
  final double exchangeRate;
  final double courierRate;
  final double packaging;

  AppConfigState({
    required this.exchangeRate,
    required this.courierRate,
    required this.packaging,
  });
}

class ConfigNotifier extends StateNotifier<AppConfigState> {
  ConfigNotifier() : super(AppConfigState(exchangeRate: 60.5, courierRate: 250.0, packaging: 50.0)) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppConfigState(
      exchangeRate: prefs.getDouble('exchangeRate') ?? 60.5,
      courierRate: prefs.getDouble('courierRate') ?? 250.0,
      packaging: prefs.getDouble('packaging') ?? 50.0,
    );
  }

  Future<void> updateConfig(double exchange, double courier, double packaging) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('exchangeRate', exchange);
    await prefs.setDouble('courierRate', courier);
    await prefs.setDouble('packaging', packaging);
    state = AppConfigState(exchangeRate: exchange, courierRate: courier, packaging: packaging);
  }
}

final configProvider = StateNotifierProvider<ConfigNotifier, AppConfigState>((ref) => ConfigNotifier());

// ============= Products State =============

class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier() : super([]) {
    refreshProducts();
  }

  Future<void> refreshProducts() async {
    final data = await DbHelper.instance.fetchProducts();
    state = data.map((item) => Product.fromMap(item)).toList();
  }

  Future<void> addProduct(Product p) async {
    await DbHelper.instance.insertProduct(p.toMap());
    await refreshProducts();
  }

  String generateAutoSKU(String brand, String? color) {
    // 1. Brand Identifier (first 2 letters uppercase)
    if (brand.length < 2) return '';
    final brandId = brand.substring(0, 2).toUpperCase();
    
    // 2. Color Identifier (optional)
    String colorId = '';
    if (color != null && color.isNotEmpty) {
      final colorLetter = color[0].toUpperCase();
      
      // Count existing variants with same brand and color letter
      final sameColorProducts = state.where((p) => 
        p.brand?.toLowerCase() == brand.toLowerCase() && 
        p.color?.isNotEmpty == true &&
        p.color![0].toUpperCase() == colorLetter
      ).length;
      
      colorId = '$colorLetter${sameColorProducts + 1}';
    }
    
    // 3. Sequence Number (chronological, 3 digits)
    final sequence = (state.length + 1).toString().padLeft(3, '0');
    
    return '$brandId$colorId$sequence';
  }

  Future<void> updateProduct(Product p) async {
    await DbHelper.instance.updateProduct(p.sku, p.toMap());
    await refreshProducts();
  }

  Future<void> deleteProduct(String sku) async {
    await DbHelper.instance.deleteProduct(sku);
    await refreshProducts();
  }

  void updateStock(String sku, int delta) {
    final index = state.indexWhere((p) => p.sku == sku);
    if (index >= 0) {
      final product = state[index];
      final newStock = product.stock + delta;
      final updated = product.copyWith(stock: newStock >= 0 ? newStock : 0);
      DbHelper.instance.updateProduct(sku, updated.toMap());
      state = [...state]..[index] = updated;
    }
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>((ref) => ProductNotifier());

// ============= Orders State =============

class OrderNotifier extends StateNotifier<List<Order>> {
  final Ref _ref;
  
  OrderNotifier(this._ref) : super([]) {
    refreshOrders();
  }

  Future<void> refreshOrders() async {
    final data = await DbHelper.instance.fetchOrders();
    state = data.map((item) => Order.fromMap(item)).toList();
  }

  Future<void> addOrder(Order order) async {
    await DbHelper.instance.insertOrder(order.toMap());
    
    // Deduct stock if not a quote
    if (order.status != OrderStatus.quote) {
      final productNotifier = _ref.read(productProvider.notifier);
      for (final item in order.items) {
        productNotifier.updateStock(item.sku, -item.quantity);
      }
    }
    
    await refreshOrders();
  }

  Future<void> updateOrder(Order updatedOrder) async {
    final oldOrder = state.firstWhere((o) => o.id == updatedOrder.id, orElse: () => updatedOrder);
    
    // Handle stock changes based on status transition
    final productNotifier = _ref.read(productProvider.notifier);
    
    // Quote -> Active: deduct stock
    if (oldOrder.status == OrderStatus.quote && 
        updatedOrder.status != OrderStatus.quote && 
        updatedOrder.status != OrderStatus.cancelled) {
      for (final item in updatedOrder.items) {
        productNotifier.updateStock(item.sku, -item.quantity);
      }
    }
    
    // Active -> Cancelled: return stock
    if (oldOrder.status != OrderStatus.quote && 
        oldOrder.status != OrderStatus.cancelled &&
        updatedOrder.status == OrderStatus.cancelled) {
      for (final item in updatedOrder.items) {
        productNotifier.updateStock(item.sku, item.quantity);
      }
    }
    
    await DbHelper.instance.updateOrder(updatedOrder.id, updatedOrder.toMap());
    await refreshOrders();
  }

  Future<void> deleteOrder(String id) async {
    await DbHelper.instance.deleteOrder(id);
    await refreshOrders();
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<Order>>((ref) => OrderNotifier(ref));

// ============= Customers State =============

class CustomerNotifier extends StateNotifier<List<Customer>> {
  CustomerNotifier() : super([]) {
    refreshCustomers();
  }

  Future<void> refreshCustomers() async {
    final data = await DbHelper.instance.fetchCustomers();
    state = data.map((item) => Customer.fromMap(item)).toList();
  }

  Future<void> addCustomer(Customer customer) async {
    await DbHelper.instance.insertCustomer(customer.toMap());
    await refreshCustomers();
  }

  Future<void> updateCustomer(Customer customer) async {
    await DbHelper.instance.updateCustomer(customer.id, customer.toMap());
    await refreshCustomers();
  }

  Future<void> deleteCustomer(String id) async {
    await DbHelper.instance.deleteCustomer(id);
    await refreshCustomers();
  }
}

final customerProvider = StateNotifierProvider<CustomerNotifier, List<Customer>>((ref) => CustomerNotifier());

// ============= Suppliers State =============

class SupplierNotifier extends StateNotifier<List<Supplier>> {
  SupplierNotifier() : super([]) {
    refreshSuppliers();
  }

  Future<void> refreshSuppliers() async {
    final data = await DbHelper.instance.fetchSuppliers();
    state = data.map((item) => Supplier.fromMap(item)).toList();
  }

  Future<void> addSupplier(Supplier supplier) async {
    await DbHelper.instance.insertSupplier(supplier.toMap());
    await refreshSuppliers();
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await DbHelper.instance.updateSupplier(supplier.id, supplier.toMap());
    await refreshSuppliers();
  }

  Future<void> deleteSupplier(String id) async {
    await DbHelper.instance.deleteSupplier(id);
    await refreshSuppliers();
  }
}

final supplierProvider = StateNotifierProvider<SupplierNotifier, List<Supplier>>((ref) => SupplierNotifier());
