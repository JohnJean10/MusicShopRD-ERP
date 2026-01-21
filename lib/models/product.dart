class Product {
  final String sku;
  final String name;
  final double costUsd;
  final double weight;
  int stock;
  int minStock;
  int maxStock;
  double price; // Selling price in RD$
  final String? supplierId; // Optional link to supplier
  final String? brand; // For SKU generation
  final String? color; // Optional color for SKU generation

  Product({
    required this.sku,
    required this.name,
    required this.costUsd,
    required this.weight,
    required this.stock,
    required this.minStock,
    required this.maxStock,
    this.price = 0,
    this.supplierId,
    this.brand,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'sku': sku,
      'name': name,
      'costUsd': costUsd,
      'weight': weight,
      'stock': stock,
      'minStock': minStock,
      'maxStock': maxStock,
      'price': price,
      'supplierId': supplierId,
      'brand': brand,
      'color': color,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      sku: map['sku'],
      name: map['name'],
      costUsd: (map['costUsd'] ?? 0).toDouble(),
      weight: (map['weight'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      minStock: map['minStock'] ?? 0,
      maxStock: map['maxStock'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      supplierId: map['supplierId'],
      brand: map['brand'],
      color: map['color'],
    );
  }

  Product copyWith({
    String? sku,
    String? name,
    double? costUsd,
    double? weight,
    int? stock,
    int? minStock,
    int? maxStock,
    double? price,
    String? supplierId,
    String? brand,
    String? color,
  }) {
    return Product(
      sku: sku ?? this.sku,
      name: name ?? this.name,
      costUsd: costUsd ?? this.costUsd,
      weight: weight ?? this.weight,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      price: price ?? this.price,
      supplierId: supplierId ?? this.supplierId,
      brand: brand ?? this.brand,
      color: color ?? this.color,
    );
  }
}
