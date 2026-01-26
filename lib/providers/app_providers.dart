import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/product_variant.dart';
import '../models/order.dart';
import '../models/customer.dart';
import '../models/supplier.dart';
import '../models/purchase_order.dart';
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

  /// Genera un SKU único para una variante basado en marca + color + secuencia
  String generateVariantSKU(String brand, String color) {
    if (brand.length < 2) return '';
    final brandId = brand.substring(0, 2).toUpperCase();
    
    String colorId = '';
    if (color.isNotEmpty) {
      final colorLetter = color[0].toUpperCase();
      
      // Contar variantes existentes con misma marca y primera letra de color
      int sameColorCount = 0;
      for (final product in state) {
        for (final variant in product.variants) {
          if (product.brand?.toLowerCase() == brand.toLowerCase() &&
              variant.color.isNotEmpty &&
              variant.color[0].toUpperCase() == colorLetter) {
            sameColorCount++;
          }
        }
      }
      colorId = '$colorLetter${sameColorCount + 1}';
    }
    
    // Secuencia total de variantes en el sistema
    int totalVariants = 0;
    for (final product in state) {
      totalVariants += product.variants.length;
    }
    final sequence = (totalVariants + 1).toString().padLeft(3, '0');
    
    return '$brandId$colorId$sequence';
  }

  /// Genera un modelId único para un producto nuevo
  String generateModelId(String brand) {
    if (brand.length < 2) return DateTime.now().millisecondsSinceEpoch.toString();
    final brandId = brand.substring(0, 3).toUpperCase();
    final sequence = (state.length + 1).toString().padLeft(4, '0');
    return 'MOD-$brandId-$sequence';
  }

  Future<void> updateProduct(Product p) async {
    await DbHelper.instance.updateProduct(p.modelId, p.toMap());
    await refreshProducts();
  }

  Future<void> deleteProduct(String modelId) async {
    await DbHelper.instance.deleteProduct(modelId);
    await refreshProducts();
  }

  /// Actualiza el stock de una variante específica
  void updateVariantStock(String variantSku, int delta) {
    for (int i = 0; i < state.length; i++) {
      final product = state[i];
      final variantIndex = product.variants.indexWhere((v) => v.sku == variantSku);
      
      if (variantIndex >= 0) {
        final variant = product.variants[variantIndex];
        final newStock = variant.stock + delta;
        variant.stock = newStock >= 0 ? newStock : 0;
        
        // Persistir el cambio
        DbHelper.instance.updateProduct(product.modelId, product.toMap());
        
        // Actualizar el estado
        state = [...state];
        return;
      }
    }
  }

  /// Agrega una nueva variante a un producto existente
  Future<void> addVariantToProduct(String modelId, ProductVariant variant) async {
    final index = state.indexWhere((p) => p.modelId == modelId);
    if (index >= 0) {
      state[index].addVariant(variant);
      await DbHelper.instance.updateProduct(modelId, state[index].toMap());
      state = [...state];
    }
  }

  /// Elimina una variante de un producto
  Future<void> removeVariantFromProduct(String modelId, String variantSku) async {
    final index = state.indexWhere((p) => p.modelId == modelId);
    if (index >= 0) {
      state[index].removeVariant(variantSku);
      await DbHelper.instance.updateProduct(modelId, state[index].toMap());
      state = [...state];
    }
  }

  /// Obtiene productos con stock bajo (agregado de todas sus variantes)
  List<Product> getLowStockProducts() {
    return state.where((p) => p.isLowStock).toList();
  }

  /// Busca un producto por el SKU de cualquiera de sus variantes
  Product? findByVariantSku(String sku) {
    for (final product in state) {
      if (product.variants.any((v) => v.sku == sku)) {
        return product;
      }
    }
    return null;
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
        productNotifier.updateVariantStock(item.sku, -item.quantity);
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
        productNotifier.updateVariantStock(item.sku, -item.quantity);
      }
    }
    
    // Active -> Cancelled: return stock
    if (oldOrder.status != OrderStatus.quote && 
        oldOrder.status != OrderStatus.cancelled &&
        updatedOrder.status == OrderStatus.cancelled) {
      for (final item in updatedOrder.items) {
        productNotifier.updateVariantStock(item.sku, item.quantity);
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

// ============= Purchase Orders State =============
// ============= Purchase Orders State =============

class PurchaseOrderNotifier extends StateNotifier<List<PurchaseOrder>> {
  final Ref _ref;

  PurchaseOrderNotifier(this._ref) : super([]) {
    refreshPurchaseOrders();
  }

  Future<void> refreshPurchaseOrders() async {
    final data = await DbHelper.instance.fetchPurchaseOrders();
    state = data.map((item) => PurchaseOrder.fromMap(item)).toList();
  }

  Future<void> addPurchaseOrder(PurchaseOrder order) async {
    await DbHelper.instance.insertPurchaseOrder(order.toMap());
    
    // If received immediately (rare but possible), add stock
    if (order.status == PurchaseOrderStatus.received) {
      final productNotifier = _ref.read(productProvider.notifier);
      for (final item in order.items) {
        productNotifier.updateVariantStock(item.sku, item.quantity);
      }
    }
    
    await refreshPurchaseOrders();
  }

  Future<void> updatePurchaseOrder(PurchaseOrder updatedOrder) async {
    final oldOrder = state.firstWhere((o) => o.id == updatedOrder.id, orElse: () => updatedOrder);
    
    // Handle stock updates on status change
    // Not received -> Received: Add stock
    if (oldOrder.status != PurchaseOrderStatus.received && 
        updatedOrder.status == PurchaseOrderStatus.received) {
      final productNotifier = _ref.read(productProvider.notifier);
      for (final item in updatedOrder.items) {
        productNotifier.updateVariantStock(item.sku, item.quantity);
      }
    }
    
    // Received -> Not received (e.g. cancelled/revert): Deduct stock
    if (oldOrder.status == PurchaseOrderStatus.received && 
        updatedOrder.status != PurchaseOrderStatus.received) {
      final productNotifier = _ref.read(productProvider.notifier);
      for (final item in updatedOrder.items) {
        productNotifier.updateVariantStock(item.sku, -item.quantity);
      }
    }
    
    await DbHelper.instance.updatePurchaseOrder(updatedOrder.id, updatedOrder.toMap());
    await refreshPurchaseOrders();
  }

  Future<void> deletePurchaseOrder(String id) async {
    // Note: Deleting a received order does NOT automatically revert stock
    // This is a design choice to prevent accidental massive stock changes
    await DbHelper.instance.deletePurchaseOrder(id);
    await refreshPurchaseOrders();
  }
}

final purchaseOrderProvider = StateNotifierProvider<PurchaseOrderNotifier, List<PurchaseOrder>>((ref) => PurchaseOrderNotifier(ref));
