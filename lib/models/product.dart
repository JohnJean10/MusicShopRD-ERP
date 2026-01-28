import 'product_variant.dart';

/// Modelo padre de producto que agrupa variantes bajo un mismo nombre comercial.
/// Por ejemplo: "KZ ZSN Pro X" puede tener variantes Negra y Dorada.
class Product {
  final String modelId;     // ID único del modelo de producto
  final String name;        // Nombre comercial del producto
  final String? brand;      // Marca del producto
  final double itemCostUsd;    // Costo del artículo en USD
  final double shippingCostUsd; // Costo de envío por unidad en USD
  final double weight;      // Peso en libras
  double price;             // Precio de venta en RD$
  int minStock;             // Stock mínimo (nivel de alerta) - global
  int maxStock;             // Stock máximo - global
  bool useIndividualMinMax; // Flag para usar min/max por variante
  final String? supplierId; // Enlace opcional con proveedor
  final String? purchaseLink; // URL de compra del proveedor
  List<ProductVariant> variants; // Lista de variantes (colores/versiones)

  Product({
    required this.modelId,
    required this.name,
    this.brand,
    required this.itemCostUsd,
    this.shippingCostUsd = 0,
    required this.weight,
    this.price = 0,
    required this.minStock,
    required this.maxStock,
    this.useIndividualMinMax = false,
    this.supplierId,
    this.purchaseLink,
    List<ProductVariant>? variants,
  }) : variants = variants ?? [];

  /// Costo total por unidad en USD (artículo + envío)
  double get totalCostUsd => itemCostUsd + shippingCostUsd;

  /// Costo "aterrizado" en RD$ (costo USD * tasa + peso * tarifa courier)
  double landedCostRds(double exchangeRate, double courierRate) {
    return (totalCostUsd * exchangeRate) + (weight * courierRate);
  }

  /// Margen de beneficio (%) basado en costo aterrizado
  double marginPercent(double exchangeRate, double courierRate) {
    final landed = landedCostRds(exchangeRate, courierRate);
    if (landed <= 0 || price <= 0) return 0;
    return ((price - landed) / landed) * 100;
  }

  /// Calcula precio desde un margen deseado
  double priceFromMargin(double marginPercent, double exchangeRate, double courierRate) {
    final landed = landedCostRds(exchangeRate, courierRate);
    return landed * (1 + marginPercent / 100);
  }

  /// Compatibilidad: getter para costUsd (devuelve itemCostUsd)
  double get costUsd => itemCostUsd;

  /// Stock total agregado de todas las variantes
  int get totalStock => variants.fold(0, (sum, v) => sum + v.stock);

  /// Indica si el stock total está por debajo del mínimo configurado
  bool get isLowStock => totalStock < minStock;

  /// SKU principal (del primer variante o modelId si no hay variantes)
  String get primarySku => variants.isNotEmpty ? variants.first.sku : modelId;

  /// Para compatibilidad: retorna el color de la primera variante
  String? get color => variants.isNotEmpty ? variants.first.color : null;

  /// Para compatibilidad: retorna el stock de la primera variante
  int get stock => totalStock;

  Map<String, dynamic> toMap() {
    return {
      'modelId': modelId,
      'name': name,
      'brand': brand,
      'itemCostUsd': itemCostUsd,
      'shippingCostUsd': shippingCostUsd,
      'weight': weight,
      'price': price,
      'minStock': minStock,
      'maxStock': maxStock,
      'useIndividualMinMax': useIndividualMinMax,
      'supplierId': supplierId,
      'purchaseLink': purchaseLink,
      'variants': variants.map((v) => v.toMap()).toList(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    // Migración: Si el mapa tiene estructura antigua (sin variants), convertir
    if (!map.containsKey('variants') || map['variants'] == null) {
      return Product._fromLegacyMap(map);
    }

    final variantsList = (map['variants'] as List<dynamic>?)
        ?.map((v) => ProductVariant.fromMap(Map<String, dynamic>.from(v)))
        .toList() ?? [];

    // Migración: soportar costUsd legado -> itemCostUsd
    final itemCost = (map['itemCostUsd'] ?? map['costUsd'] ?? 0).toDouble();

    return Product(
      modelId: map['modelId'] ?? map['sku'] ?? '',
      name: map['name'] ?? '',
      brand: map['brand'],
      itemCostUsd: itemCost,
      shippingCostUsd: (map['shippingCostUsd'] ?? 0).toDouble(),
      weight: (map['weight'] ?? 0).toDouble(),
      price: (map['price'] ?? 0).toDouble(),
      minStock: map['minStock'] ?? 0,
      maxStock: map['maxStock'] ?? 0,
      useIndividualMinMax: map['useIndividualMinMax'] ?? false,
      supplierId: map['supplierId'],
      purchaseLink: map['purchaseLink'],
      variants: variantsList,
    );
  }

  /// Convierte formato antiguo (sin variantes) al nuevo formato
  factory Product._fromLegacyMap(Map<String, dynamic> map) {
    final legacyVariant = ProductVariant(
      sku: map['sku'] ?? '',
      color: map['color'] ?? 'Default',
      stock: map['stock'] ?? 0,
    );

    // Migración: soportar costUsd legado -> itemCostUsd
    final itemCost = (map['itemCostUsd'] ?? map['costUsd'] ?? 0).toDouble();

    return Product(
      modelId: map['sku'] ?? '', // Usar SKU antiguo como modelId
      name: map['name'] ?? '',
      brand: map['brand'],
      itemCostUsd: itemCost,
      shippingCostUsd: (map['shippingCostUsd'] ?? 0).toDouble(),
      weight: (map['weight'] ?? 0).toDouble(),
      price: (map['price'] ?? 0).toDouble(),
      minStock: map['minStock'] ?? 0,
      maxStock: map['maxStock'] ?? 0,
      useIndividualMinMax: map['useIndividualMinMax'] ?? false,
      supplierId: map['supplierId'],
      purchaseLink: map['purchaseLink'],
      variants: [legacyVariant],
    );
  }

  Product copyWith({
    String? modelId,
    String? name,
    String? brand,
    double? itemCostUsd,
    double? shippingCostUsd,
    double? weight,
    double? price,
    int? minStock,
    int? maxStock,
    bool? useIndividualMinMax,
    String? supplierId,
    String? purchaseLink,
    List<ProductVariant>? variants,
  }) {
    return Product(
      modelId: modelId ?? this.modelId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      itemCostUsd: itemCostUsd ?? this.itemCostUsd,
      shippingCostUsd: shippingCostUsd ?? this.shippingCostUsd,
      weight: weight ?? this.weight,
      price: price ?? this.price,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      useIndividualMinMax: useIndividualMinMax ?? this.useIndividualMinMax,
      supplierId: supplierId ?? this.supplierId,
      purchaseLink: purchaseLink ?? this.purchaseLink,
      variants: variants ?? List.from(this.variants),
    );
  }

  /// Agrega una nueva variante al producto
  void addVariant(ProductVariant variant) {
    variants.add(variant);
  }

  /// Elimina una variante por su SKU
  bool removeVariant(String sku) {
    final index = variants.indexWhere((v) => v.sku == sku);
    if (index >= 0) {
      variants.removeAt(index);
      return true;
    }
    return false;
  }

  /// Actualiza el stock de una variante específica
  void updateVariantStock(String sku, int newStock) {
    final variant = variants.firstWhere(
      (v) => v.sku == sku,
      orElse: () => throw Exception('Variante no encontrada: $sku'),
    );
    variant.stock = newStock;
  }

  /// Obtiene una variante por su SKU
  ProductVariant? getVariant(String sku) {
    try {
      return variants.firstWhere((v) => v.sku == sku);
    } catch (e) {
      return null;
    }
  }
}
